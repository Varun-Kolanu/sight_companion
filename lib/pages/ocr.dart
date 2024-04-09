import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:sight_companion/utils/text_to_speech.dart';

class Ocr extends StatefulWidget {
  const Ocr({super.key});

  @override
  State<Ocr> createState() => OcrState();
}

class OcrState extends State<Ocr> {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  RecognizedText? _recognizedText;
  String? _text;
  final MyTts tts = MyTts();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      _recognizedText = await _textRecognizer
          .processImage(InputImage.fromFile(File(pickedImage.path)));
      setState(() {
        _text = _recognizedText!.text;
      });
      await tts.speak(_recognizedText!.text);
      await _textRecognizer.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            Text(
              _text ?? "",
            ),
          ],
        ),
      ),
    );
  }
}
