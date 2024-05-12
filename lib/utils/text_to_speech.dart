import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sight_companion/utils/tts_state.dart';

class Tts {
  late FlutterTts flutterTts;
  String? engine;
  TtsState ttsState = TtsState.initialized;

  // Singleton instance
  static final Tts _instance = Tts._internal();

  factory Tts() => _instance;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  Tts._internal() {
    flutterTts = FlutterTts();
    initTts();
  }

  Future<void> initTts() async {
    await _setAwaitOptions();
    if (isAndroid) {
      await _getDefaultEngine();
    }

    flutterTts.setStartHandler(() {
      ttsState = TtsState.playing;
    });

    flutterTts.setCompletionHandler(() {
      ttsState = TtsState.stopped;
    });

    flutterTts.setCancelHandler(() {
      ttsState = TtsState.stopped;
    });

    flutterTts.setPauseHandler(() {
      ttsState = TtsState.paused;
    });

    flutterTts.setContinueHandler(() {
      ttsState = TtsState.continued;
    });

    flutterTts.setErrorHandler((msg) {
      ttsState = TtsState.stopped;
    });
  }

  Future<void> _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setLanguage("en-US");
  }

  Future<void> _getDefaultEngine() async {
    engine = await flutterTts.getDefaultEngine;
  }

  Future<void> stop() async {
    var result = await flutterTts.stop();
    if (result == 1) {
      ttsState = TtsState.stopped;
    }
  }

  Future<void> speak(String text) async {
    await flutterTts.awaitSpeakCompletion(true);
    var result = await flutterTts.speak(text);
    if (result == 1) {
      ttsState = TtsState.playing;
    }
  }

  Future<void> pause() async {
    var result = await flutterTts.pause();
    if (result == 1) {
      ttsState = TtsState.paused;
    }
  }

  Future<void> setLanguage(String language) async {
    await flutterTts.setLanguage(language);
  }
}
