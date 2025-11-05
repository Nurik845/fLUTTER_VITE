import 'package:flutter/widgets.dart';

class L {
  final Locale locale;
  L(this.locale);

  static const supported = [Locale('kk'), Locale('ru'), Locale('en')];

  static L of(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    return L(locale);
  }

  String _t(String key) {
    final lang = locale.languageCode;
    final map = _localizedValues[lang] ?? _localizedValues['en']!;
    return map[key] ?? key;
  }

  String get appName => _t('appName');
  String get tabHome => _t('tabHome');
  String get tabDiagnose => _t('tabDiagnose');
  String get tabMap => _t('tabMap');
  String get tabEmergency => _t('tabEmergency');
  String get tabSupport => _t('tabSupport');
  String get tabSettings => _t('tabSettings');
  String get tabWellness => _t('tabWellness');
  String get hello => _t('hello');
  String get speakHint => _t('speakHint');
  String get start => _t('start');
  String get stop => _t('stop');
  String get call103 => _t('call103');
  String get call112 => _t('call112');
  String get smsGps => _t('smsGps');
  String get enterPhone => _t('enterPhone');
  String get diagnose => _t('diagnose');
  String get pickPhoto => _t('pickPhoto');
  String get speakSymptoms => _t('speakSymptoms');
  String get result => _t('result');
  String get mapTitle => _t('mapTitle');
  String get yourLocation => _t('yourLocation');
  String get supportTitle => _t('supportTitle');
  String get messageHint => _t('messageHint');
  String get language => _t('language');
  String get kazakh => _t('kazakh');
  String get russian => _t('russian');
  String get english => _t('english');
  String get lumiIntro => _t('lumiIntro');
  String get hotline => _t('hotline');
  String get listening => _t('listening');
  String get notListening => _t('notListening');

  static const Map<String, Map<String, String>> _localizedValues = {
    'kk': {
      'appName': 'VITA',
      'tabHome': 'LUMI',
      'tabDiagnose': 'Диагностика',
      'tabMap': 'Карта',
      'tabEmergency': 'Жедел көмек',
      'tabSupport': 'Қолдау',
      'tabSettings': 'Баптау',
      'tabWellness': 'Денсаулық',
      'hello': 'Сәлем! Мен LUMI.',
      'speakHint': 'Айт: "Lumi, жедел жәрдем шақыр"',
      'start': 'Бастау',
      'stop': 'Тоқтату',
      'call103': '103 қоңырау',
      'call112': '112 қоңырау',
      'smsGps': 'SMS + GPS',
      'enterPhone': 'Телефон нөмірі',
      'diagnose': 'Диагностика',
      'pickPhoto': 'Жара суреті',
      'speakSymptoms': 'Симптомдарды айтыңыз',
      'result': 'Нәтиже',
      'mapTitle': 'Жақын ауруханалар мен дәріханалар',
      'yourLocation': 'Сіздің орналасуыңыз',
      'supportTitle': 'Мен осындамын. Әңгімелесейік',
      'messageHint': 'Хабарлама...',
      'language': 'Тіл',
      'kazakh': 'Қазақша',
      'russian': 'Орысша',
      'english': 'Ағылшынша',
      'lumiIntro': 'Мен LUMI — көмектесуге дайынмын.',
      'hotline': 'Жедел желі: 988 / 112',
      'listening': 'Тыңдап тұрмын...',
      'notListening': 'Микрофон өшірулі',
    },
    'ru': {
      'appName': 'VITA',
      'tabHome': 'LUMI',
      'tabDiagnose': 'Диагностика',
      'tabMap': 'Карта',
      'tabEmergency': 'Экстренно',
      'tabSupport': 'Поддержка',
      'tabSettings': 'Настройки',
      'tabWellness': 'Здоровье',
      'hello': 'Привет! Я LUMI.',
      'speakHint': 'Скажи: "Lumi, вызови скорую"',
      'start': 'Старт',
      'stop': 'Стоп',
      'call103': 'Позвонить 103',
      'call112': 'Позвонить 112',
      'smsGps': 'SMS + GPS',
      'enterPhone': 'Номер телефона',
      'diagnose': 'Диагноз',
      'pickPhoto': 'Фото раны',
      'speakSymptoms': 'Скажи симптомы',
      'result': 'Результат',
      'mapTitle': 'Ближайшие больницы и аптеки',
      'yourLocation': 'Ваше местоположение',
      'supportTitle': 'Я здесь. Давай поговорим',
      'messageHint': 'Сообщение...',
      'language': 'Язык',
      'kazakh': 'Казахский',
      'russian': 'Русский',
      'english': 'Английский',
      'lumiIntro': 'Я LUMI — здесь, чтобы помочь.',
      'hotline': 'Горячая линия: 988 / 112',
      'listening': 'Слушаю...',
      'notListening': 'Микрофон выкл.',
    },
    'en': {
      'appName': 'VITA',
      'tabHome': 'LUMI',
      'tabDiagnose': 'Diagnose',
      'tabMap': 'Map',
      'tabEmergency': 'Emergency',
      'tabSupport': 'Support',
      'tabSettings': 'Settings',
      'tabWellness': 'Wellness',
      'hello': 'Hi! I am LUMI.',
      'speakHint': 'Say: "Lumi, call ambulance"',
      'start': 'Start',
      'stop': 'Stop',
      'call103': 'Call 103',
      'call112': 'Call 112',
      'smsGps': 'SMS + GPS',
      'enterPhone': 'Phone number',
      'diagnose': 'Diagnosis',
      'pickPhoto': 'Wound photo',
      'speakSymptoms': 'Speak symptoms',
      'result': 'Result',
      'mapTitle': 'Nearby hospitals and pharmacies',
      'yourLocation': 'Your location',
      'supportTitle': 'I am here. Let’s talk',
      'messageHint': 'Message...',
      'language': 'Language',
      'kazakh': 'Kazakh',
      'russian': 'Russian',
      'english': 'English',
      'lumiIntro': 'I’m LUMI — here to help.',
      'hotline': 'Hotline: 988 / 112',
      'listening': 'Listening...',
      'notListening': 'Mic off',
    },
  };
}

