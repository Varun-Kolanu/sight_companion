import 'dart:core';
import 'package:flutter/material.dart';
import 'package:sight_companion/pages/Home.dart';
import 'package:sight_companion/pages/bar_code_scanner.dart';
import 'package:sight_companion/pages/braille_reader.dart';
import 'package:sight_companion/pages/object_detection.dart';
import 'package:sight_companion/pages/ocr.dart';
import 'package:sight_companion/pages/speech_to_text_page.dart';
import 'package:sight_companion/pages/text_to_speech.dart';
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
      // home: const TextToSpeechPage(),
      // home: const SpeechToTextHomePage(),
      // home: const Ocr(),
      // home: BrailleReaderApp(),
      // home: const BarCodeScannerPage(),
      // home: NavigationPage(),
      routes: {
        '/barcode': (context) => const BarCodeScannerPage(),
        '/braille': (context) => const BrailleReaderApp(),
        '/object_detection': (context) => const ObjectDetectionPage(),
        '/ocr': (context) => const Ocr(),
        '/speech_to_text': (context) => const SpeechToTextHomePage(),
        '/text_to_speech': (context) => const TextToSpeechPage(),
      },
    );
  }
}
