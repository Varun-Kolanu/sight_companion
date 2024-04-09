import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sight_companion/utils/tts_state.dart';

class MyTts {
  late FlutterTts flutterTts;
  String? engine;
  TtsState ttsState = TtsState.initialized;

  // Singleton instance
  static final MyTts _instance = MyTts._internal();

  factory MyTts() => _instance;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  MyTts._internal() {
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
    while (!(await flutterTts.isLanguageAvailable("en-US"))) {
      await Future.delayed(const Duration(seconds: 1));
      continue;
    }
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
