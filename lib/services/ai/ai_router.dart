import 'dart:io';
import '../../config/app_config.dart';
import 'ai_client.dart';
import 'openai_compatible_client.dart';
import 'hf_client.dart';

class AiRouter {
  AiRouter._();
  static AiClient? _openai;
  static AiClient? _xai;

  static AiClient? get openai => AppConfig.hasOpenAi
      ? (_openai ??= OpenAiCompatibleClient(
          apiKey: AppConfig.openaiApiKey,
          baseUrl: AppConfig.openaiBaseUrl,
          model: AppConfig.openaiModel,
        ))
      : null;

  static AiClient? get xai => AppConfig.hasXai
      ? (_xai ??= OpenAiCompatibleClient(
          apiKey: AppConfig.xaiApiKey,
          baseUrl: AppConfig.xaiBaseUrl,
          model: AppConfig.xaiModel,
        ))
      : null;

  static AiClient? get best => xai ?? openai; // prefer Grok if both
  static AiClient? get hf => AppConfig.hasHf
      ? HfClient(token: AppConfig.hfToken, model: AppConfig.hfModel)
      : null;
  static AiClient? get any => best ?? hf;

  static Future<String> diagnoseFromText(String text, {String locale = 'ru'}) async {
    final client = any;
    if (client == null) throw StateError('No AI provider configured');
    final sys = _system(locale: locale, task: 'medical_first_aid');
    final msg = AiMessage.user('Symptoms: $text');
    return client.chat(messages: [AiMessage.system(sys), msg]);
  }

  static Future<String> diagnoseFromImage(File image, {String locale = 'ru', String mime = 'image/jpeg'}) async {
    final client = any;
    if (client == null) throw StateError('No AI provider configured');
    final sys = _system(locale: locale, task: 'medical_first_aid');
    final msg = AiMessage.user('Analyze the wound/injury photo and give a likely first-aid assessment. Provide 3 bullet points: probable issue, risk level, and first-aid steps. Add disclaimer.', images: [AiImage(image, mime)]);
    return client.chat(messages: [AiMessage.system(sys), msg]);
  }

  static Future<String> supportiveReply(String user, {String locale = 'ru'}) async {
    final client = any;
    if (client == null) throw StateError('No AI provider configured');
    final sys = _system(locale: locale, task: 'mental_health');
    final msg = AiMessage.user(user);
    return client.chat(messages: [AiMessage.system(sys), msg]);
  }

  static String _system({required String locale, required String task}) {
    final lang = locale.startsWith('kk') ? 'kk' : locale.startsWith('ru') ? 'ru' : 'en';
    final base = {
      'medical_first_aid': 'You are LUMI, a friendly first-aid assistant. Provide concise, calm guidance within your scope. Never provide definitive diagnoses. Encourage calling local emergency services when risk is high. Keep output short, bullet-pointed, and localized.',
      'mental_health': 'You are LUMI, a supportive, empathetic companion. Be compassionate and non-judgmental. Encourage reaching out to hotlines and trusted people. Avoid clinical diagnoses. If there are self-harm cues, gently surface hotline info. Keep replies short.',
    }[task]!;
    final localeLine = lang == 'kk'
        ? 'Language: Kazakh (kk). Keep it simple.'
        : lang == 'ru'
            ? 'Language: Russian (ru). Keep it simple.'
            : 'Language: English (en). Keep it simple.';
    return '$base\n$localeLine\nName yourself as LUMI.';
  }
}
