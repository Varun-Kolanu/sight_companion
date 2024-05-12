import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sight_companion/utils/colors_detection.dart';
import 'package:sight_companion/utils/feature_enum.dart';
import 'package:sight_companion/utils/object_detection.dart';
import 'package:sight_companion/utils/ocr.dart';
import 'package:sight_companion/utils/qr.dart';
import 'package:sight_companion/utils/speech_to_text.dart';
import 'package:sight_companion/utils/stt_state.dart';
import 'package:sight_companion/utils/text_to_speech.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = false;
  Feature _currentFeature = Feature.none;

  final List<String> _instructions = [
    "Instructions:",
    "Tap the screen to start speaking or stop speaking",
    "List of feature available are Object Detection, Color Detection, QR Code scanner, Document Reader",
    "You can use these features by speech",
    "Example prompts are, 'Open Object Detection', 'Repeat Instructions' etc",
  ];

  final Stt _stt = Stt();
  SttState _status = SttState.stopped;

  final ObjectDetector _objD = ObjectDetector();
  File _image = File('');

  Tts _tts = Tts();

  final Ocr _ocr = Ocr();
  String _recognizedText = "";

  final Qr _qr = Qr();

  late ImagePicker _imagePicker;

  String _domColor = '';

  @override
  void initState() {
    super.initState();
    _stt.callback = _onSpeechResult;
    _objD.loadModel();
    _imagePicker = ImagePicker();
  }

  void _handleTap() async {
    if (_status != SttState.listening) {
      print("Start Speaking...");
      await _stt.startListening();
    } else {
      await _stt.stopListening();
    }
  }

  Feature _getFeature(String text) {
    final lower = text.toLowerCase();
    if (lower.contains("object") || lower.contains("thing")) {
      return Feature.objectDetection;
    } else if (lower.contains("ocr") ||
        lower.contains("document") ||
        lower.contains("read")) {
      return Feature.ocr;
    } else if (lower.contains("color") || lower.contains("colour")) {
      return Feature.colorDetection;
    } else if (lower.contains("qr") ||
        lower.contains("barcode") ||
        lower.contains("bar code")) {
      return Feature.qrScanner;
    } else if (lower.contains("instructions")) {
      return Feature.instructions;
    } else {
      return Feature.none;
    }
  }

  void _onSpeechResult(String text, SttState status, String emitted) async {
    setState(() {
      _status = status;
      _loading = true;
    });
    if (emitted == 'done' || emitted == 'stop') {
      Feature feat = _getFeature(text);
      setState(() {
        _currentFeature = feat;
      });
      if (feat != Feature.qrScanner &&
          feat != Feature.instructions &&
          feat != Feature.none) {
        await _tts.speak(
          "Opening Camera. Tap bottom right after capturing pic to confirm",
        );

        var image = await _imagePicker.pickImage(
          source: ImageSource.camera,
        );

        while (!(await _tts.flutterTts.isLanguageAvailable("en-US"))) {
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }
        if (feat == Feature.objectDetection) {
          setState(() {
            _image = File(image!.path);
          });
          await _objD.predict(image);
          setState(() {
            _loading = false;
          });
          return;
        } else if (feat == Feature.colorDetection) {
          String dominantColor = await calculateDominantColor(image);
          setState(() {
            _domColor = dominantColor;
          });
          setState(() {
            _loading = false;
          });
          await _tts.speak("The dominant color is $dominantColor");
          return;
        } else if (feat == Feature.ocr) {
          String recText = await _ocr.read(image!);
          setState(() {
            _recognizedText = recText;
            _loading = false;
          });
          await _tts.speak(recText);
          return;
        }
      } else if (feat == Feature.qrScanner) {
        await _qr.openScanner(context);
        setState(() {
          _loading = false;
        });
      } else if (feat == Feature.instructions) {
        setState(() {
          _loading = false;
        });
        for (String str in _instructions) {
          await _tts.speak(str);
        }
      } else {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
        ),
        body: GestureDetector(
          onTap: _handleTap,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _buildFeature(),
            ),
          ),
        ));
  }

  Widget _buildFeature() {
    switch (_currentFeature) {
      case Feature.none || Feature.instructions:
        return ListView.builder(
          itemCount: _instructions.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Text(
                _instructions[index],
                style: TextStyle(fontSize: 16.0),
              ),
            );
          },
        );
      case Feature.objectDetection:
        return Stack(
          children: _objD.stackChildrenObj(MediaQuery.of(context).size, _image),
        );
      case Feature.ocr:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Text(_recognizedText),
        );
      case Feature.colorDetection:
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: colorMap[_domColor],
        );
      case Feature.qrScanner:
        return Text(_qr.result);
      default:
        return const Text("Hello");
    }
  }
}
