import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sight_companion/pages/object_detection.dart';
import 'package:sight_companion/pages/ocr.dart';
import 'package:sight_companion/utils/colors_detection.dart';
import 'package:sight_companion/utils/speech_to_text.dart';
import 'package:sight_companion/utils/stt_state.dart';
import 'package:sight_companion/utils/text_to_speech.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class ListeningFloatingActionButton extends StatefulWidget {
  const ListeningFloatingActionButton({super.key});

  @override
  State<ListeningFloatingActionButton> createState() =>
      _ListeningFloatingActionButtonState();
}

class _ListeningFloatingActionButtonState
    extends State<ListeningFloatingActionButton> {
  final MyStt _stt = MyStt();
  SttState _status = SttState.stopped;
  String _text = "";
  MyTts tts = MyTts();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _stt.callback = _onSpeechResult;
  }

  Future<void> _launchInBrowserView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _onSpeechResult(String text, SttState status, String emitted) async {
    if (mounted) {
      setState(() {
        _status = status;
        if (emitted != 'done') {
          _text = text;
        }
      });

      // Check if the last words contain keywords 'QR' or 'Bar code scanner'
      if (emitted == 'done') {
        final lower = _text.toLowerCase();
        _text = "";
        if (lower.contains('qr') ||
            lower.contains('bar code') ||
            lower.contains('barcode')) {
          var res = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SimpleBarcodeScannerPage(),
              ));
          Uri? uri = Uri.tryParse(res);
          if (uri != null && uri.hasScheme && uri.hasAuthority) {
            setState(() {
              loading = true;
            });
            await tts.speak("Opening domain ${uri.host}");
            setState(() {
              loading = false;
            });
            await _launchInBrowserView(uri);
          } else {
            setState(() {
              loading = true;
            });
            await tts.speak("The url is not valid. QR returned $res");
            setState(() {
              loading = false;
            });
          }
        } else if (lower.contains("ocr") ||
            lower.contains("document") ||
            lower.contains("reader")) {
          var image = await ImagePicker().pickImage(source: ImageSource.camera);
          RecognizedText recognizedText;
          if (image != null) {
            final textRecognizer =
                TextRecognizer(script: TextRecognitionScript.latin);

            recognizedText = await textRecognizer
                .processImage(InputImage.fromFile(File(image.path)));
            setState(() {
              _text = recognizedText.text;
              loading = true;
            });
            await tts.speak(recognizedText.text);
            setState(() {
              loading = false;
            });
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Ocr(
                          text: recognizedText.text,
                        )));
            await textRecognizer.close();
          }
        } else if (lower.contains("object")) {
          var image = await ImagePicker().pickImage(source: ImageSource.camera);
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ObjectDetectionPage(imageFile: image),
              ));
        } else if (lower.contains('color') || lower.contains('colour')) {
          var image = await ImagePicker().pickImage(source: ImageSource.camera);
          String color = await calculateDominantColor(image);
          setState(() {
            loading = true;
          });
          await tts.speak("It is $color color");
          setState(() {
            loading = false;
          });
        }
      }
    }
  }

  Future<void> _handleButtonClick() async {
    if (_status != SttState.listening) {
      await _stt.startListening();
    } else {
      await _stt.stopListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const CircularProgressIndicator()
        : FloatingActionButton(
            onPressed: _handleButtonClick,
            tooltip: 'Start/Stop Listening',
            child: Icon(
                _status == SttState.listening ? Icons.mic : Icons.mic_none),
          );
  }
}
