import 'dart:io';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:sight_companion/components/listening_floating.dart';
import 'package:sight_companion/utils/text_to_speech.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';

class ObjectDetectionPage extends StatefulWidget {
  final XFile? imageFile;

  const ObjectDetectionPage({super.key, this.imageFile});

  @override
  State<ObjectDetectionPage> createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetectionPage> {
  File _image = File('');
  List? _recognitions;
  double _imageHeight = 0;
  double _imageWidth = 0;
  bool _busy = false;

  MyTts tts = MyTts();

  Future pickImageAndPredict() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      _busy = true;
    });
    predictImage(File(image!.path));
  }

  Future predictImage(File image) async {
    FileImage(image)
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageHeight = info.image.height.toDouble();
        _imageWidth = info.image.width.toDouble();
      });
    }));

    var recognitions = await Tflite.detectObjectOnImage(
      path: image.path,
      numResultsPerClass: 1,
    );

    var classes = recognitions!
        .where((re) => re["confidenceInClass"] >= 0.45)
        .map((re) => re["detectedClass"]);

    await tts.speak("The objects infront of you are ");
    for (String word in classes) {
      await tts.speak(word);
      // Add some delay between speaking each word if needed
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() {
      _image = File(image.path);
      _recognitions = recognitions;
      _busy = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _busy = true;
    _image = File(widget.imageFile!.path);

    loadModel().then((val) {
      setState(() {
        _busy = false;
      });
      predictImage(File(widget.imageFile!.path));
    });
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String? res = await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
        // useGpuDelegate: true,
      );
      return res;
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  List<Widget> renderBoxes(Size screen) {
    if (_recognitions == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight / _imageWidth * screen.width;
    Color blue = const Color.fromRGBO(37, 213, 253, 1.0);
    return _recognitions!.map((re) {
      if (re["confidenceInClass"] < 0.45) {
        return Container();
      }
      return Positioned(
        left: re["rect"]["x"] * factorX,
        top: re["rect"]["y"] * factorY,
        width: re["rect"]["w"] * factorX,
        height: re["rect"]["h"] * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            border: Border.all(
              color: blue,
              width: 2,
            ),
          ),
          child: Text(
            "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = blue,
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];

    stackChildren.add(
      ElevatedButton(
        onPressed: pickImageAndPredict,
        child: const Text("Open Camera"),
      ),
    );
    stackChildren.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        child: _image.path.isEmpty
            ? const Text('No image selected.')
            : Image.file(_image),
      ),
    );

    stackChildren.addAll(renderBoxes(size));
    stackChildren.add(ElevatedButton(
      onPressed: pickImageAndPredict,
      child: const Text("Open Camera"),
    ));

    if (_busy) {
      stackChildren.add(const Opacity(
        opacity: 0.3,
        child: ModalBarrier(
          dismissible: false,
          color: Colors.grey,
        ),
      ));
      stackChildren.add(const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tflite sample",
        ),
      ),
      body: Stack(
        children: stackChildren,
      ),
      floatingActionButton: const ListeningFloatingActionButton(),
    );
  }
}
