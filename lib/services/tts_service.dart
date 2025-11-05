import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/widgets.dart';

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _initIfNeeded() async {
    if (_initialized) return;
    await _tts.setSpeechRate(0.44);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1);
    try { await _tts.awaitSpeakCompletion(true); } catch (_) {}
    _initialized = true;
  }

  Future<void> speak(String text, {String? langCode}) async {
    await _initIfNeeded();
    langCode ??= _resolveLang();
    if (langCode.isNotEmpty) { await _setLanguageAndVoice(langCode, cheerful: false); }
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();

  Future<void> speakCheerful(String text, {String? langCode}) async {
    await _initIfNeeded();
    langCode ??= _resolveLang();
    if (langCode.isNotEmpty) { await _setLanguageAndVoice(langCode, cheerful: true); }
    try {
      await _tts.setPitch(1.15);
      await _tts.setSpeechRate(0.48);
    } catch (_) {}
    await _tts.stop();
    await _tts.speak(text);
    try {
      await _tts.setPitch(1.1);
      await _tts.setSpeechRate(0.44);
    } catch (_) {}
  }

  Future<void> _setLanguageAndVoice(String langCode, {required bool cheerful}) async {
    try { await _tts.setLanguage(langCode); } catch (_) {}
    try {
      final v = await _tts.getVoices;
      if (v is! List) return;
      final List<Map<String, dynamic>> voices = v.whereType<Map>().map((e)=> e.map((k, v)=> MapEntry(k.toString(), v))).toList();
      final short = langCode.split('-').first.toLowerCase();
      bool matches(Map m){ final loc=(m['locale']??m['Locale']??'').toString().toLowerCase(); return loc.startsWith(short); }
      bool pref(Map m){ final name=(m['name']??m['Name']??'').toString().toLowerCase();
        final keys=['female','neural','natural','wave','bright'];
        return cheerful ? keys.any((k)=>name.contains(k)) : true; }
      final list = voices.where(matches).toList();
      list.sort((a,b){ int s(Map m){ final n=(m['name']??'').toString().toLowerCase(); int sc=0; if(n.contains('female')) sc+=2; if(n.contains('neural')||n.contains('natural')) sc+=2; if(n.contains('wave')) sc+=1; return sc; } return s(b)-s(a); });
      final chosen = (list.where(pref).isNotEmpty ? list.where(pref).first : (list.isNotEmpty ? list.first : null));
      if (chosen!=null) {
        await _tts.setVoice({'name': chosen['name']??chosen['Name'], 'locale': chosen['locale']??chosen['Locale']});
      }
    } catch (_) {}
  }

  String _resolveLang() {
    try {
      final lc = WidgetsBinding.instance.platformDispatcher.locale.languageCode.toLowerCase();
      switch (lc) {
        case 'ru':
          return 'ru-RU';
        case 'kk':
          return 'kk-KZ';
        case 'en':
        default:
          return 'en-US';
      }
    } catch (_) {
      return 'en-US';
    }
  }
}
