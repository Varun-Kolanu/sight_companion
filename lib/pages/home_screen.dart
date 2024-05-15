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
import 'package:sight_companion/utils/tts_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = false;
  Feature _currentFeature = Feature.none;

  final List<String> _instructionsList = [
    "Instructions",
    "Tap anywhere on the screen to start speaking or stop speaking",
    "List of feature available are Object Detection, Color Detection, QR Code scanner, Document Reader",
    "You can use these features by speech",
    "Example prompts are, 'Open Object Detection', 'Repeat Instructions' etc",
  ];

  final String _instructions = """
Instructions
Tap anywhere on the screen to start speaking or stop speaking
List of feature available are Object Detection, Color Detection, QR Code scanner, Document Reader
You can use these features by speech
Example prompts are, 'Open Object Detection', 'Repeat Instructions' etc
""";

  final Stt _stt = Stt();
  SttState _status = SttState.stopped;

  final ObjectDetector _objD = ObjectDetector();
  File _image = File('');

  final Tts _tts = Tts();

  final Ocr _ocr = Ocr();
  String _recognizedText = "";

  final Qr _qr = Qr();
  String? _qrText = "";

  late ImagePicker _imagePicker;

  String _domColor = '';

  @override
  void initState() {
    super.initState();
    _stt.callback = _onSpeechResult;
    _objD.loadModel();
    _imagePicker = ImagePicker();
    repeatInstructions();
  }

  void repeatInstructions() async {
    await _tts.speak(_instructions);
  }

  void _handleTap() async {
    if (_status != SttState.listening) {
      await _stt.startListening();
    } else {
      await _stt.stopListening();
    }
    if (_tts.ttsState == TtsState.playing) await _tts.stop();
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
    } else if (lower.contains("instruction") || lower.contains("detail")) {
      return Feature.instructions;
    } else {
      return Feature.none;
    }
  }

  void _onSpeechResult(String text, SttState status, String emitted) async {
    setState(() {
      _status = status;
      if (emitted != "stop") {
        _loading = true;
      }
    });
    if (emitted == 'done') {
      Feature feat = _getFeature(text);
      if (feat == Feature.none) {
        setState(() {
          _loading = false;
        });
        return;
      } else {
        setState(() {
          _currentFeature = feat;
        });
      }
      if (feat != Feature.qrScanner &&
          feat != Feature.instructions &&
          feat != Feature.none) {
        await _tts.speak(
          "Opening Camera. Tap bottom right after capturing picture, to confirm",
        );

        late XFile? image;
        image = await _imagePicker.pickImage(
          source: ImageSource.camera,
        );
        if (image == null) {
          setState(() {
            _loading = false;
            return;
          });
        }

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
        String result = await _qr.openScanner(context);
        setState(() {
          _loading = false;
          _qrText = result;
        });
        Uri? uri = Uri.tryParse(result);
        if (uri != null && uri.hasScheme && uri.hasAuthority) {
          await _tts.speak("Opening domain ${uri.host}");
          await _qr.launchInBrowserView(uri);
        } else {
          await _tts.speak("Scanned Text is: $result");
        }
      } else if (feat == Feature.instructions) {
        setState(() {
          _loading = false;
        });
        await _tts.speak(_instructions);
      } else {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  bool _isUriValid(String url) {
    Uri? uri = Uri.tryParse(url);
    return (uri != null && uri.hasScheme && uri.hasAuthority);
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
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            GestureDetector(
              onTap: _handleTap,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent, // Set color to transparent
              ),
            ),
            if (_loading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              GestureDetector(
                onTap: _handleTap,
                child:
                    _buildFeature(), // Replace _buildFeature() with your widget
              ),
          ],
        ));
  }

  Widget _buildFeature() {
    switch (_currentFeature) {
      case Feature.none || Feature.instructions:
        return Container(
          color: Colors.blue[200],
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: _instructionsList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  color: Colors.blue[500],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _instructionsList[index],
                      style: TextStyle(
                        fontSize: index == 0 ? 24.0 : 16.0,
                        color: Colors.white,
                      ),
                      textAlign: index == 0 ? TextAlign.center : TextAlign.left,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      case Feature.objectDetection:
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.blue[100],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.center,
              children:
                  _objD.stackChildrenObj(MediaQuery.of(context).size, _image),
            ),
          ),
        );
      case Feature.ocr:
        return Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.blue[400],
          child: SingleChildScrollView(
            child: Text(
              _recognizedText,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        );
      case Feature.colorDetection:
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: colorMap[_domColor],
        );
      case Feature.qrScanner:
        return Center(
          child: _isUriValid(_qrText!)
              ? TextButton(
                  onPressed: () {
                    _qr.launchInBrowserView(Uri.parse(_qrText!));
                  },
                  child: Text(
                    _qrText!,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              : Text(_qrText!),
        );
      default:
        return const Text("Hello");
    }
  }
}
