import 'package:flutter/material.dart';
import '../widgets/lumi_overlay.dart';
import '../widgets/lumi_widget.dart';
import '../services/tts_service.dart';
import '../services/profile_service.dart';
import 'dart:math' as math;

enum LumiAction { idle, login, success, fail, talk, listen, map, emergency, diagnose }

class LumiBrain {
  LumiBrain._();
  static final LumiBrain instance = LumiBrain._();
  static final LumiBrain I = instance; // alias

  String? _name;
  TimeOfDay _time = const TimeOfDay(hour: 12, minute: 0);

  Future<void> init() async { _name = await ProfileService.getName(); }
  void setName(String name) { _name = name; ProfileService.setName(name); }
  String get name => _name ?? 'друг';
  final Map<String,int> _lastIndex = {};
  DateTime? _lastSpokeAt;
  final Duration _cooldown = const Duration(seconds: 2);

  void onAppStart() {
    _time = TimeOfDay.now();
    final h = _time.hour;
    final morning = [
      'Доброе утро, $name!',
      'С добрым утром! Как самочувствие?',
      'Я рядом и готов помочь. Начнём день?'
    ];
    final day = [
      'Привет, $name! Чем помочь сегодня?',
      'Я слушаю. Хочешь консультацию или карту поблизости?',
      'Если нужно — подскажу ближайшую клинику.'
    ];
    final evening = [
      'Добрый вечер, $name.',
      'Как прошёл день? Давай позаботимся о здоровье.',
      'Хочешь дыхательную практику для расслабления?'
    ];
    final night = [
      'Доброй ночи, $name.',
      'Если не спишь — я рядом.',
      'Включить спокойный режим и напомнить про сон?'
    ];
    if (h >= 6 && h < 12) {
      _say('start', LumiEmotion.happy, morning, cheerful: true);
    } else if (h >= 12 && h < 18) {
      _say('start', LumiEmotion.neutral, day);
    } else if (h >= 18 && h < 23) {
      _say('start', LumiEmotion.care, evening);
    } else {
      _say('start', LumiEmotion.sleepy, night);
    }
  }

  void onLoginSuccess() {
    _say('login', LumiEmotion.happy, [
      'Ура! Мы вместе, $name.',
      'Отлично! Готов помогать.',
      'Добро пожаловать! Чем займёмся?'
    ], cheerful: true);
  }
  void onLoginFail(String reason) {
    _say('login_fail', LumiEmotion.sad, [
      'Не удалось войти. Проверь данные и попробуем ещё раз.'
    ]);
  }
  void onMapOpen() {
    _say('map', LumiEmotion.curious, [
      'Ищем рядом аптеки и клиники.',
      'Скажи, что ищешь: аптеку или больницу?',
      'Готов показать маршрут до ближайшего места.'
    ]);
  }
  void onEmergency() {
    _say('emergency', LumiEmotion.anxious, [
      'Активирую экстренный режим. Дыши спокойно.',
      'Если нужно, вызову 103 или 112.',
      'Готов отправить SMS с GPS контактам.'
    ]);
  }
  void onDiagnosisSuccess() {
    _say('diag_ok', LumiEmotion.excited, [
      'Готово! Я подготовил рекомендации.',
      'Есть результат, $name! Посмотри.',
      'Диагностика завершена. Продолжаем?'
    ], cheerful: true);
  }
  void onListen() {
    _say('listen', LumiEmotion.listening, [
      'Слушаю тебя.',
      'Говори, я рядом.',
      'Я внимательно слушаю.'
    ]);
  }
  void onSpeak(String text) { _set(LumiEmotion.speaking, text); }

  void onHomeOpen() {
    _say('home', LumiEmotion.happy, [
      'Привет, $name! Что делаем?',
      'Готов помочь. Выбирай: карта, диагноз, здоровье.',
      'Если хочешь, подскажу, с чего начать.'
    ], cheerful: true);
  }
  void onDiagnoseStart() {
    _say('diag', LumiEmotion.curious, [
      'Расскажи о симптомах. Есть температура? Болит где-то?',
      'Есть аллергии или хронические заболевания?',
      'Прикрепи фото, если нужно — я посмотрю.'
    ]);
  }
  void onWellnessOpen() {
    _say('well', LumiEmotion.happy, [
      'Настроим питание и план тренировок?',
      'Хочешь включить режим Спорт и цель на неделю?',
      'Давай улучшим индекс здоровья!'
    ], cheerful: true);
  }
  void onSupportOpen() {
    _say('support', LumiEmotion.care, [
      'Я здесь. Давай поговорим?',
      'Ты важен. Если тяжело — я рядом.',
      'Можем позвонить на горячую линию — только скажи.'
    ]);
  }
  void onSettingsOpen() {
    _say('settings', LumiEmotion.neutral, [
      'Настроим язык, голос и уведомления.',
      'Хочешь сделать Lumi ярче или тише?',
      'Выбери удобный режим.'
    ]);
  }

  void _set(LumiEmotion e, String? speech, {bool cheerful = false}) {
    LumiOverlay.set(emotion: e, speech: speech);
    if (speech != null && speech.isNotEmpty) {
      if (_lastSpokeAt != null && DateTime.now().difference(_lastSpokeAt!) < _cooldown) {
        return; // avoid spam
      }
      if (cheerful) {
        TtsService.instance.speakCheerful(speech);
      } else {
        TtsService.instance.speak(speech);
      }
      _lastSpokeAt = DateTime.now();
    }
  }

  void _say(String key, LumiEmotion e, List<String> variants, {bool cheerful = false}) {
    final last = _lastIndex[key] ?? -1;
    int idx = math.Random().nextInt(variants.length);
    if (variants.length > 1 && idx == last) {
      idx = (idx + 1) % variants.length;
    }
    _lastIndex[key] = idx;
    _set(e, variants[idx], cheerful: cheerful);
  }
}

