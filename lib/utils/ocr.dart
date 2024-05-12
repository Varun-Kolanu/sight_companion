import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sight_companion/utils/text_to_speech.dart';

class Ocr {
  late TextRecognizer _textRecognizer;
  String? recognizedText;
  final Tts _tts = Tts();

  static final Ocr _instance = Ocr._internal();

  factory Ocr() => _instance;
  Ocr._internal() {
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  Future<String> read(XFile image) async {
    recognizedText = (await _textRecognizer
            .processImage(InputImage.fromFile(File(image.path))))
        .text;
    await _textRecognizer.close();
    return recognizedText!;
  }
}
