import 'package:flutter/material.dart';
import 'package:sight_companion/utils/text_to_speech.dart';
import 'package:sight_companion/utils/tts_state.dart';

class TextToSpeechPage extends StatefulWidget {
  const TextToSpeechPage({super.key});

  @override
  State<TextToSpeechPage> createState() => _TextToSpeechPageState();
}

class _TextToSpeechPageState extends State<TextToSpeechPage> {
  MyTts tts = MyTts();
  List<dynamic> languages = ["en-US"];
  String selectedLanguage = 'en-US';
  TextEditingController textEditingController = TextEditingController();

  Future<void> _speak(String text) async {
    await tts.speak(text);
  }

  Future<void> _stop() async {
    await tts.stop();
  }

  Future<void> _pause() async {
    await tts.pause();
  }

  void _changeLanguage(String? language) async {
    if (language != null) {
      await tts.setLanguage(language);
      setState(() {
        selectedLanguage = language;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text to Speech Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: textEditingController,
              decoration: const InputDecoration(
                labelText: 'Enter text',
              ),
            ),
            DropdownButton<String>(
              value: selectedLanguage,
              onChanged: _changeLanguage,
              items:
                  languages.map<DropdownMenuItem<String>>((dynamic language) {
                return DropdownMenuItem<String>(
                  value: language.toString(),
                  child: Text(language.toString()),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: tts.ttsState == TtsState.playing
                  ? _pause
                  : () => _speak(textEditingController.text),
              child: Text(tts.ttsState == TtsState.playing ? 'Pause' : 'Speak'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stop,
              child: const Text('Stop'),
            ),
            ElevatedButton(
              onPressed: _pause,
              child: const Text('Pause'),
            ),
          ],
        ),
      ),
    );
  }
}
