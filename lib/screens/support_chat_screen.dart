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

  void _botSay(String text) {
    setState(() => _messages.add((sender: 'lumi', text: text)));
    TtsService.instance.speak(text);
    LumiOverlay.set(emotion: LumiEmotion.happy, speech: text);
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
      AiRouter.supportiveReply(
        user,
        locale: lang,
      ).then((reply) => _botSay(reply)).catchError((_) {
        _fallbackReply(t, l);
      });
    } else {
      _fallbackReply(t, l);
    }
  }

  void _fallbackReply(String t, L l) {
    if (t.contains('умер') ||
        t.contains('суиц') ||
        t.contains('die') ||
        t.contains('kill myself')) {
      _botSay('${l.supportTitle}. ${l.hotline}');
      return;
    }
    if (t.contains('страх') || t.contains('паник') || t.contains('anx')) {
      _botSay('Дышим вместе 4-4-4. Вдох 4, задержка 4, выдох 4.');
      return;
    }
    _botSay('Я с тобой. Расскажи, что чувствуешь?');
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
