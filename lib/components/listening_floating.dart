import 'package:flutter/material.dart';
import 'package:sight_companion/utils/speech_to_text.dart';
import 'package:sight_companion/utils/stt_state.dart';

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

  @override
  void initState() {
    super.initState();
    _stt.callback = _onSpeechResult;
  }

  void _onSpeechResult(String text, SttState status, String emitted) {
    setState(() {
      _status = status;
      if (emitted != 'done') {
        _text = text;
      }
    });

    // Check if the last words contain keywords 'QR' or 'Bar code scanner'
    if (emitted == 'done') {
      if (_text.contains('QR') || _text.contains('Bar code')) {
        _text = '';
        setState(() {});
        Navigator.pushNamed(context, '/barcode');
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
    return FloatingActionButton(
      onPressed: _handleButtonClick,
      tooltip: 'Start/Stop Listening',
      child: Icon(_status == SttState.listening ? Icons.mic : Icons.mic_none),
    );
  }
}
