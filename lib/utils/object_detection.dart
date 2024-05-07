import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_v2/tflite_v2.dart';

class ObjectDetector {
  List<dynamic>? _recognitions;
  Iterable<dynamic> classes = [];
  double _imageHeight = 0;
  double _imageWidth = 0;

  static final ObjectDetector _instance = ObjectDetector._internal();

  factory ObjectDetector() => _instance;
  ObjectDetector._internal() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    Tflite.close();
    try {
      await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
      );
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  Future<void> predictImage(File image) async {
    FileImage(image)
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      _imageHeight = info.image.height.toDouble();
      _imageWidth = info.image.width.toDouble();
    }));

    var recognitions = await Tflite.detectObjectOnImage(
      path: image.path,
      numResultsPerClass: 1,
    );

    _recognitions = recognitions;

    classes = recognitions!
        .where((re) => re["confidenceInClass"] >= 0.45)
        .map((re) => re["detectedClass"]);
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
}
