import 'package:flutter/material.dart';
import '../l10n/localization.dart';
import '../services/tts_service.dart';
import '../config/app_config.dart';
import '../services/ai/ai_router.dart';
import '../widgets/lumi_overlay.dart';
import '../widgets/lumi_widget.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});
  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _controller = TextEditingController();
  final _messages = <({String sender, String text})>[];
  bool _useAi = true;

  final _topics = const [
    ('🚭 Бросить курить', 'У меня проблемы с курением. Помоги составить план отказа от никотина по методикам CBT и мотивационного интервьюирования. Спроси про триггеры, привычки и поддерживающие шаги.'),
    ('🍺 Алкоголь', 'Алкоголь мешает мне. Помоги уменьшить/прекратить употребление. Используй техники мотивационного интервьюирования (MI), SMART-цели и план на 7 дней.'),
    ('🧠 Тревожность/стресс', 'У меня тревога/стресс. Дай дыхательные техники, когнитивные переоценки, упражнения на заземление. Спроси про триггеры и режим сна.'),
    ('🆘 Суицидальные мысли', 'Мне очень тяжело. Помоги безопасным планом и поддержкой. Дай шаги безопасности, контакты горячей линии и предложи обратиться к специалисту. Говори бережно.'),
    ('🎮 Зависимость от игр', 'Проблема с играми. Помоги ограничить время, убрать триггеры, предложи альтернативы и контроль прогресса на 14 дней.'),
  ];

  void _botSay(String text) {
    setState(() => _messages.add((sender: 'lumi', text: text)));
    TtsService.instance.speak(text);
    LumiOverlay.set(emotion: LumiEmotion.care, speech: text);
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add((sender: 'you', text: text)));
    _controller.clear();
    _respond(text);
    LumiOverlay.set(emotion: LumiEmotion.listening, speech: '...');
  }

  void _respond(String user) {
    final l = L.of(context);
    final t = user.toLowerCase();
    final hasAi = AppConfig.hasOpenAi || AppConfig.hasXai;
    if (_useAi && hasAi) {
      final lang = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
      AiRouter.supportiveReply(user, locale: lang)
          .then((reply) => _botSay(reply))
          .catchError((_) => _fallbackReply(t, l));
    } else {
      _fallbackReply(t, l);
    }
  }

  void _fallbackReply(String t, L l) {
    if (t.contains('умереть') || t.contains('суицид') || t.contains('die') || t.contains('kill myself')) {
      _botSay('${l.supportTitle}. ${l.hotline}');
      return;
    }
    if (t.contains('тревог') || t.contains('паник') || t.contains('anx')) {
      _botSay('Давай попробуем дыхание 4-7-8: вдох 4, задержка 7, выдох 8. Ещё вариант — заземление 5-4-3-2-1.');
      return;
    }
    _botSay('Я здесь. Расскажи, что чувствуешь. Я постараюсь помочь и подсказать план.');
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Column(
      children: [
        ListTile(
          title: Text(l.supportTitle),
          subtitle: Text(l.hotline),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('AI'),
              Switch(
                value: _useAi && (AppConfig.hasOpenAi || AppConfig.hasXai),
                onChanged: (v) => setState(() => _useAi = v),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _topics
                .map((tp) => ActionChip(
                      label: Text(tp.$1),
                      onPressed: () {
                        final seed = tp.$2;
                        setState(() => _messages.add((sender: 'you', text: tp.$1)));
                        _respond(seed);
                      },
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (context, i) {
              final m = _messages[i];
              final isMe = m.sender == 'you';
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue.shade100 : Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(m.text),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: l.messageHint,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _send, child: const Icon(Icons.send)),
            ],
          ),
        ),
      ],
    );
  }
}

