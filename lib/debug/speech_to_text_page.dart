import 'package:flutter/material.dart';
import 'package:sight_companion/utils/speech_to_text.dart';
import 'package:sight_companion/utils/stt_state.dart';

class SpeechToTextHomePage extends StatefulWidget {
  const SpeechToTextHomePage({super.key});

  @override
  State<SpeechToTextHomePage> createState() => _SpeechToTextHomePageState();
}

class _SpeechToTextHomePageState extends State<SpeechToTextHomePage> {
  final MyStt _stt = MyStt();
  String _text = '';
  SttState _status = SttState.stopped;

  Future<void> _click() async {
    if (_status != SttState.listening) {
      await _stt.startListening();
    } else {
      await _stt.stopListening();
    }
  }

  void _listenHandler(String text, SttState status, String emitted) {
    setState(() {
      _text = text;
      _status = status;
    });
  }

  @override
  void initState() {
    super.initState();
    _stt.callback = _listenHandler;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech to Text Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              (_status == SttState.listening)
                  ? 'Listening...'
                  : 'Not Listening',
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 20.0),
            Text(
              _text,
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _click,
        tooltip: 'Listen',
        child: Icon(
          (_status == SttState.listening) ? Icons.mic : Icons.mic_none,
        ),
      ),
    );
  }
}
