import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sight_companion/utils/object_detection.dart';
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

  final Stt _stt = Stt();
  SttState _status = SttState.stopped;

  final ObjectDetector _objD = ObjectDetector();
  File _image = File('');

  final Tts _tts = Tts();

  @override
  void initState() {
    super.initState();
    _stt.callback = _onSpeechResult;
  }

  void _handleTap() async {
    if (_status != SttState.listening) {
      print("Start Speaking...");
      await _stt.startListening();
    } else {
      await _stt.stopListening();
    }
  }

  void _onSpeechResult(String text, SttState status, String emitted) async {
    // if (mounted) {
    setState(() {
      _status = status;
    });
    if (emitted == 'done') {
      final lower = text.toLowerCase();
      if (lower.contains("object") || lower.contains("thing")) {
        await _pickImageAndPredict();
      }
    }
    // }
  }

  Future<void> _pickImageAndPredict() async {
    setState(() {
      _loading = true;
    });
    await _tts.speak(
      "Touch Shutter button at bottom center and then tick button at bottom right.",
    );
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    await _objD.predictImage(File(image!.path));
    setState(() {
      _loading = false;
      _image = File(image.path);
    });
    await _tts.speak("The objects infront of you are ");
    for (String word in _objD.classes) {
      await _tts.speak(word);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  List<Widget> _stackChildrenObj(Size screen) {
    List<Widget> st = [];
    st.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: screen.width,
        child: _image.path.isEmpty
            ? const Text('No image selected.')
            : Image.file(_image),
      ),
    );

    st.addAll(_objD.renderBoxes(screen));
    return st;
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
            child: Column(
              children: _objD.classes.isEmpty
                  ? [
                      const Text(
                        "Hello",
                      ),
                    ]
                  : _stackChildrenObj(MediaQuery.of(context).size),
            ),
          ),
        ));
  }
}
