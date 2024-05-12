import 'dart:core';
import 'package:flutter/material.dart';
import 'package:sight_companion/pages/home_screen.dart';
import 'package:sight_companion/utils/object_detection.dart';
import 'package:sight_companion/utils/ocr.dart';
import 'package:sight_companion/utils/speech_to_text.dart';
import 'package:sight_companion/utils/text_to_speech.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Tts();
    Stt();
    ObjectDetector();
    Ocr();
    return const MaterialApp(
      title: 'Sight Companion',
      home: HomeScreen(),
    );
  }
}
