import 'dart:io';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';

class ObjectDetectionPage extends StatefulWidget {
  const ObjectDetectionPage({super.key});

  @override
  State<ObjectDetectionPage> createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetectionPage> {
  File _image = File('');
  List? _recognitions;
  double _imageHeight = 0;
  double _imageWidth = 0;
  bool _busy = false;

  Color? dominantColor;

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

    setState(() {
      _image = File(image.path);
      _recognitions = recognitions;
      _busy = false;
    });

    print(await _calculateDominantColor());
  }

  @override
  void initState() {
    super.initState();

    _busy = true;

    loadModel().then((val) {
      setState(() {
        _busy = false;
      });
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
      if (re["confidenceInClass"] < 0.5) {
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

  int _colorDistance(Color a, Color b) {
    return (a.red - b.red) * (a.red - b.red) +
        (a.green - b.green) * (a.green - b.green) +
        (a.blue - b.blue) * (a.blue - b.blue);
  }

  Future<String> _calculateDominantColor() async {
    Uint8List bytes = await _image.readAsBytes();
    ImageProvider<Object> imageProvider =
        MemoryImage(Uint8List.fromList(bytes));
    PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      imageProvider,
    );
    Color? domColor = paletteGenerator.dominantColor?.color;

    Map<String, Color> colorMap = {
      'White': Colors.white,
      'Black': Colors.black,
      'Blue': Colors.blue,
      'Red': Colors.red,
      'Yellow': Colors.yellow,
      'Grey': Colors.grey,
      'Orange': Colors.orange,
      'Purple': Colors.purple,
      'Green': Colors.green,
      'Brown': Colors.brown,
      'Pink': Colors.pink,
      'Cyan': Colors.cyan
    };
    int minDistance = 200000;
    String nearestColor = '';
    for (var entry in colorMap.entries) {
      int colorDist = _colorDistance(domColor!, entry.value);
      if (colorDist < minDistance) {
        minDistance = colorDist;
        nearestColor = entry.key;
      }
    }
    return nearestColor;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];

    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      child: _image.path.isEmpty
          ? const Text('No image selected.')
          : Image.file(_image),
    ));

    stackChildren.addAll(renderBoxes(size));

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
      floatingActionButton: FloatingActionButton(
        onPressed: pickImageAndPredict,
        tooltip: 'Pick Image',
        child: const Icon(Icons.image),
      ),
    );
  }
}
