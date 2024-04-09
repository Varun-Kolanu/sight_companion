import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:sight_companion/components/listening_floating.dart';
import 'package:sight_companion/utils/text_to_speech.dart';

class Ocr extends StatefulWidget {
  final String? text;

  const Ocr({super.key, this.text});

  @override
  State<Ocr> createState() => OcrState();
}

class OcrState extends State<Ocr> {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  RecognizedText? _recognizedText;
  String? _text;
  final MyTts tts = MyTts();
  bool loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      _recognizedText = await _textRecognizer
          .processImage(InputImage.fromFile(File(pickedImage.path)));
      setState(() {
        _text = _recognizedText!.text;
      });
      setState(() {
        loading = true;
      });
      await tts.speak(_recognizedText!.text);
      setState(() {
        loading = false;
      });
      await _textRecognizer.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const CircularProgressIndicator()
        : Scaffold(
            appBar: AppBar(
              title: const Text('OCR'),
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Pick Image'),
                    ),
                    const SizedBox(
                        height: 20), // Add some spacing below the button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        widget.text ?? (_text ?? ""),
                        textAlign: TextAlign.center, // Align text to the center
                        style: const TextStyle(
                          fontSize:
                              20, // Increase font size for better visibility
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: loading
                ? const CircularProgressIndicator()
                : const ListeningFloatingActionButton(),
          );
  }
}
