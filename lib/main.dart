import 'dart:core';
import 'package:flutter/material.dart';
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              children: [
                MediumButton(
                  color: Colors.red,
                  text: 'QR Scanner',
                  onTap: () {
                    Navigator.pushNamed(context, '/barcode');
                  },
                ),
                MediumButton(
                  color: Colors.green,
                  text: 'Text To Braille',
                  onTap: () {
                    Navigator.pushNamed(context, '/braille');
                  },
                ),
                MediumButton(
                  color: Colors.blue,
                  text: 'Object Detection',
                  onTap: () {
                    Navigator.pushNamed(context, '/object_detection');
                  },
                ),
                MediumButton(
                  color: Colors.blue,
                  text: 'Document to Text',
                  onTap: () {
                    Navigator.pushNamed(context, '/ocr');
                  },
                ),
                MediumButton(
                  color: Colors.blue,
                  text: 'Speech To Text',
                  onTap: () {
                    Navigator.pushNamed(context, '/speech_to_text');
                  },
                ),
                MediumButton(
                  color: Colors.blue,
                  text: 'Text To Speech',
                  onTap: () {
                    Navigator.pushNamed(context, '/text_to_speech');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      // floatingActionButton: SpeechActionButton(),
    );
  }
}

class MediumButton extends StatelessWidget {
  final Color color;
  final String text;
  final VoidCallback onTap;

  const MediumButton({
    super.key,
    required this.color,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 150,
        color: color,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
