import 'package:flutter/material.dart';
import '../l10n/localization.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';

typedef LocaleSetter = void Function(Locale? locale);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onSetLocale});
  final LocaleSetter onSetLocale;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(title: Text(l.language)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              onPressed: () => onSetLocale(const Locale('kk')),
              child: Text(l.kazakh),
            ),
            OutlinedButton(
              onPressed: () => onSetLocale(const Locale('ru')),
              child: Text(l.russian),
            ),
            OutlinedButton(
              onPressed: () => onSetLocale(const Locale('en')),
              child: Text(l.english),
            ),
            OutlinedButton(
              onPressed: () => onSetLocale(null),
              child: const Text('Auto'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        const Text('AI Providers'),
        const SizedBox(height: 8),
        _aiStatus(),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        const Text('Account'),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton.tonalIcon(
              onPressed: () => AuthService.instance.signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
            const SizedBox(width: 8),
            if (AuthService.instance.demoMode) ...[
              const Text('(guest mode)', style: TextStyle(color: Colors.grey)),
            ],
          ],
        ),
        const SizedBox(height: 24),
        const Text('Tips: Allow location and microphone for the full demo.'),
      ],
    );
  }

  Widget _aiStatus() {
    final items = <String>[];
    if (AppConfig.hasXai) items.add('Grok (xAI): ${AppConfig.xaiModel}');
    if (AppConfig.hasOpenAi) {
      items.add('ChatGPT (OpenAI): ${AppConfig.openaiModel}');
    }
    if (items.isEmpty) {
      return const Text('AI: not configured. Add API keys via --dart-define.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((e) => Text('- $e')).toList(),
    );
  }
}

