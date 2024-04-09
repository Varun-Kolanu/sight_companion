import 'package:sight_companion/utils/stt_state.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

typedef SpeechRecognitionResultCallback = void Function(
  String text,
  SttState status,
  String emitted,
);

class MyStt {
  late SpeechToText stt;
  List<LocaleName> localeNames = [];
  String lastWords = "";
  bool hasSpeech = false;
  SpeechRecognitionResultCallback? callback;
  SpeechListenOptions listenOptions = SpeechListenOptions(
      cancelOnError: true, listenMode: ListenMode.dictation);

  static final MyStt _instance = MyStt._internal();

  factory MyStt() => _instance;
  MyStt._internal() {
    stt = SpeechToText();
    initStt();
  }

  Future<void> initStt() async {
    try {
      await stt.initialize(
        onStatus: (status) {
          print('status: $status');
          if (status == 'done') {
            lastWords = "";
            callback?.call(lastWords, SttState.stopped, 'done');
          } else {
            callback?.call(lastWords, SttState.listening, 'listening');
          }
          hasSpeech = true;
        },
        onError: (error) {
          print('error: $error');
          lastWords = "";
          callback?.call(lastWords, SttState.stopped, 'stop');
          hasSpeech = false;
        },
      );

      if (hasSpeech) {
        // Get the list of languages installed on the supporting platform so they
        // can be displayed in the UI for selection by the user.
        localeNames = await stt.locales();
      }
    } catch (e) {
      print('Speech recognition failed: ${e.toString()}');
    }
  }

  Future<void> startListening() async {
    print("Listening...");
    await stt.listen(
        onResult: (SpeechRecognitionResult result) {
          lastWords = result.recognizedWords;
          print(result.recognizedWords);
          callback?.call(result.recognizedWords, SttState.listening, 'result');
        },
        listenOptions: listenOptions);
  }

  Future<void> stopListening() async {
    await stt.stop();
    print("Stopped Listening...");
    lastWords = "";
    callback?.call(lastWords, SttState.stopped, 'done');
  }
}
