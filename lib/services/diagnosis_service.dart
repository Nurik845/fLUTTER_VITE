import 'dart:io';
import '../config/app_config.dart';
import 'ai/ai_router.dart';

class DiagnosisResult {
  final String label;
  final double confidence;
  DiagnosisResult(this.label, this.confidence);
}

class DiagnosisService {
  // Uses AI if configured, otherwise a placeholder heuristic.
  static Future<DiagnosisResult> fromText(
    String text, {
    String lang = 'ru',
  }) async {
    if (AppConfig.hasOpenAi || AppConfig.hasXai) {
      try {
        final out = await AiRouter.diagnoseFromText(text, locale: lang);
        return DiagnosisResult(out, 0.85);
      } catch (_) {
        /* fall through */
      }
    }
    final t = text.toLowerCase();
    if (t.contains('жар') ||
        t.contains('тепло') ||
        t.contains('жарық') ||
        t.contains('heat')) {
      return DiagnosisResult('Тепловой удар / Heat stroke', 0.8);
    }
    if (t.contains('укус') || t.contains('укусила') || t.contains('bite')) {
      return DiagnosisResult('Укус насекомого / Insect bite', 0.7);
    }
    if (t.contains('голова') || t.contains('бас') || t.contains('headache')) {
      return DiagnosisResult('Головная боль / Headache', 0.6);
    }
    return DiagnosisResult('Неопределённо / Uncertain', 0.4);
  }

  static Future<DiagnosisResult> fromImage(
    File file, {
    String lang = 'ru',
  }) async {
    if (AppConfig.hasOpenAi || AppConfig.hasXai) {
      try {
        final out = await AiRouter.diagnoseFromImage(file, locale: lang);
        return DiagnosisResult(out, 0.85);
      } catch (_) {
        /* fall through */
      }
    }
    return DiagnosisResult('Вероятно: укус насекомого', 0.75);
  }
}
