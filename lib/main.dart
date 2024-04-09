import 'dart:core';
import 'package:flutter/material.dart';
import 'package:sight_companion/pages/Home.dart';
import 'package:sight_companion/pages/ocr.dart';
import 'package:sight_companion/utils/speech_to_text.dart';
import 'package:sight_companion/utils/text_to_speech.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    MyTts();
    MyStt();
    return MaterialApp(
      title: 'Tflite tutorial',
      home: const HomePage(),
      routes: {
        '/ocr': (context) => const Ocr(),
      },
    );
  }
}
