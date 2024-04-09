import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sight_companion/utils/tts_state.dart';

class MyTts {
  late FlutterTts _flutterTts;
  String? engine;
  TtsState ttsState = TtsState.initialized;

  // Singleton instance
  static final MyTts _instance = MyTts._internal();

  factory MyTts() => _instance;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  MyTts._internal() {
    _flutterTts = FlutterTts();
    initTts();
  }

  Future<void> initTts() async {
    await _setAwaitOptions();
    if (isAndroid) {
      await _getDefaultEngine();
    }

    _flutterTts.setStartHandler(() {
      ttsState = TtsState.playing;
    });

    _flutterTts.setCompletionHandler(() {
      ttsState = TtsState.stopped;
    });

    _flutterTts.setCancelHandler(() {
      ttsState = TtsState.stopped;
    });

    _flutterTts.setPauseHandler(() {
      ttsState = TtsState.paused;
    });

    _flutterTts.setContinueHandler(() {
      ttsState = TtsState.continued;
    });

    _flutterTts.setErrorHandler((msg) {
      ttsState = TtsState.stopped;
    });
  }

  Future<void> _setAwaitOptions() async {
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setLanguage("en-US");
  }

  Future<void> _getDefaultEngine() async {
    engine = await _flutterTts.getDefaultEngine;
  }

  Future<void> stop() async {
    var result = await _flutterTts.stop();
    if (result == 1) {
      ttsState = TtsState.stopped;
    }
  }

  Future<void> speak(String text) async {
    var result = await _flutterTts.speak(text);
    if (result == 1) {
      ttsState = TtsState.playing;
    }
  }

  Future<void> pause() async {
    var result = await _flutterTts.pause();
    if (result == 1) {
      ttsState = TtsState.paused;
    }
  }

  Future<void> setLanguage(String language) async {
    await _flutterTts.setLanguage(language);
  }
}
