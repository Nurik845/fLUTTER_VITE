import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;

typedef SttResult = void Function(String text, bool finalResult);

class SttService {
  SttService._();
  static final SttService instance = SttService._();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _available = false;

  Future<bool> init() async {
    _available = await _speech.initialize();
    return _available;
  }

  bool get isListening => _speech.isListening;

  Future<bool> start({String localeId = 'ru_RU', SttResult? onResult}) async {
    if (!_available) {
      final ok = await init();
      if (!ok) return false;
    }
    await _speech.listen(
      localeId: localeId,
      onResult: (r) => onResult?.call(r.recognizedWords, r.finalResult),
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
      ),
    );
    return _speech.isListening;
  }

  Future<void> stop() => _speech.stop();
  Future<void> cancel() => _speech.cancel();
}
