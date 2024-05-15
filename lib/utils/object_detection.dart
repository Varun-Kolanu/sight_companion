import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sight_companion/utils/text_to_speech.dart';
import 'package:tflite_v2/tflite_v2.dart';

class ObjectDetector {
  List<dynamic>? _recognitions;
  Iterable<dynamic> classes = [];
  double _imageHeight = 0;
  double _imageWidth = 0;
  final Tts _tts = Tts();

  static final ObjectDetector _instance = ObjectDetector._internal();

  factory ObjectDetector() => _instance;
  ObjectDetector._internal();

  Future<void> loadModel() async {
    // Tflite.close();
    try {
      await Tflite.loadModel(
        model: "assets/yolo.tflite",
        labels: "assets/yolo.txt",
      );
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  Future<void> predict(XFile? image) async {
    await _predictImage(File(image!.path));
    await _tts.speak("The objects infront of you are ");
    for (String word in classes) {
      await _tts.speak(word);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> _predictImage(File image) async {
    FileImage(image)
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      _imageHeight = info.image.height.toDouble();
      _imageWidth = info.image.width.toDouble();
    }));

    var recognitions = await Tflite.detectObjectOnImage(
      path: image.path,
      model: "YOLO",
      threshold: 0.01,
      imageMean: 0.0,
      imageStd: 255.0,
      numResultsPerClass: 1,
    );

    _recognitions =
        recognitions!.where((re) => re["confidenceInClass"] >= 0.2).toList();

    classes = recognitions
        .where((re) => re["confidenceInClass"] >= 0.2)
        .map((re) => re["detectedClass"]);
  }

  List<Widget> _renderBoxes(Size screen) {
    if (_recognitions == null) return [];
    print("Not null");

    double factorX = screen.width;
    double factorY = _imageHeight / _imageWidth * screen.width;
    Color blue = const Color.fromRGBO(37, 213, 253, 1.0);
    return _recognitions!.map((re) {
      if (re["confidenceInClass"] < 0.2) {
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

  List<Widget> stackChildrenObj(Size screen, File image) {
    List<Widget> st = [];
    st.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: screen.width,
        child: image.path.isEmpty
            ? const Text('No image selected.')
            : Image.file(image),
      ),
    );

    st.addAll(_renderBoxes(screen));
    return st;
  }
}
