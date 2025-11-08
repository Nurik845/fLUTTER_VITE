import 'package:flutter/material.dart';
import '../l10n/localization.dart';
import '../services/tts_service.dart';
import '../services/stt_service.dart';
import '../widgets/lumi_overlay.dart';
import '../widgets/lumi_widget.dart';
import '../widgets/lumi_aware_button.dart';
import 'ar_lumi_screen.dart';
import '../services/profile_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onCommand});
  final void Function(String command)? onCommand;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool speaking = false;
  bool listening = false;
  String lastHeard = '';
  List<String> _family = [];
  String _plan = 'basic';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakIntro());
    _loadFamily();
  }

  Future<void> _speakIntro() async {
    final l = L.of(context);
    LumiOverlay.set(emotion: LumiEmotion.happy, speech: l.lumiIntro);
    setState(() => speaking = true);
    await TtsService.instance.speak(l.lumiIntro);
    if (mounted) setState(() => speaking = false);
    LumiOverlay.set(emotion: LumiEmotion.neutral, speech: null);
  }

  Future<void> _loadFamily() async {
    final fam = await ProfileService.getFamily();
    final plan = await ProfileService.getPlan();
    if (!mounted) return;
    setState(() {
      _family = fam;
      _plan = plan;
    });
  }

  void _handleStt(String text, bool finalResult) {
    setState(() => lastHeard = text);
    if (!finalResult) return;
    LumiOverlay.set(emotion: LumiEmotion.excited, speech: '"$text"');
    final cmd = text.toLowerCase();
    if (cmd.contains('скорую') ||
        cmd.contains('экстренно') ||
        cmd.contains('жедел') ||
        cmd.contains('103') ||
        cmd.contains('112') ||
        cmd.contains('ambulance') ||
        cmd.contains('emergency')) {
      widget.onCommand?.call('emergency_call');
    } else if (cmd.contains('аптек') || cmd.contains('pharmacy') || cmd.contains('drugstore')) {
      widget.onCommand?.call('map_pharmacy');
    } else if (cmd.contains('больниц') || cmd.contains('клиник') || cmd.contains('hospital')) {
      widget.onCommand?.call('map_hospital');
    } else if (cmd.contains('диагноз') || cmd.contains('диагност') || cmd.contains('diagnos')) {
      widget.onCommand?.call('diagnose');
    }
  }

  Future<void> _toggleMic() async {
    if (SttService.instance.isListening) {
      await SttService.instance.stop();
      setState(() => listening = false);
      return;
    }
    LumiOverlay.set(emotion: LumiEmotion.listening, speech: L.of(context).listening);
    final ok = await SttService.instance.start(
      localeId: (Localizations.maybeLocaleOf(context)?.toLanguageTag() ?? 'en-US').replaceAll('-', '_'),
      onResult: _handleStt,
    );
    setState(() => listening = ok);
    if (!ok) LumiOverlay.set(emotion: LumiEmotion.neutral, speech: null);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const SizedBox(height: 8),
          Text(l.hello, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(l.speakHint, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          _quickActions(l),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _toggleMic,
            icon: Icon(listening ? Icons.stop_circle : Icons.mic),
            label: Text(listening ? l.stop : l.start),
          ),
          const SizedBox(height: 8),
          Text(listening ? l.listening : l.notListening, style: TextStyle(color: Colors.grey[600])),
          if (lastHeard.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('"$lastHeard"', textAlign: TextAlign.center),
          ],
          const SizedBox(height: 16),
          _tipsCard(),
          const SizedBox(height: 16),
          _familyCard(),
          const SizedBox(height: 16),
          _subscriptionCardFinal(),
        ],
      ),
    );
  }

  Widget _quickActions(L l) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick actions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 4,
              children: [
                _qa(Icons.sos, l.tabEmergency, () => widget.onCommand?.call('emergency_call')),
                _qa(Icons.local_pharmacy, 'Pharmacy', () => widget.onCommand?.call('map_pharmacy')),
                _qa(Icons.local_hospital, 'Hospital', () => widget.onCommand?.call('map_hospital')),
                _qa(Icons.healing, l.tabDiagnose, () => widget.onCommand?.call('diagnose')),
                _qa(Icons.view_in_ar, 'AR Mode', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ArLumiScreen()))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _qa(IconData icon, String label, VoidCallback onTap) {
    return LumiAwareButton(
      onPressed: onTap,
      emotionOnTap: LumiEmotion.curious,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircleAvatar(radius: 22, child: Icon(icon)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ]),
    );
  }

  Widget _tipsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Daily tips'),
          SizedBox(height: 8),
          Text('• Пей воду: 2 литра в день\n• Дыхание 4–7–8 перед сном\n• 10 минут прогулки после еды'),
        ]),
      ),
    );
  }

  int _familyLimit() {
    switch (_plan) {
      case 'vip':
        return 10;
      case 'premium':
        return 25;
      default:
        return 5;
    }
  }

  Widget _familyCard() {
    final limit = _familyLimit();
    final canAdd = _family.length < limit;
    final nameCtl = TextEditingController();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Family mode'),
          const SizedBox(height: 8),
          Text('Members: ${_family.length} / $limit'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _family
                .map((m) => Chip(
                      label: Text(m),
                      onDeleted: () async {
                        final next = [..._family]..remove(m);
                        await ProfileService.setFamily(next);
                        setState(() => _family = next);
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: nameCtl, decoration: const InputDecoration(hintText: 'Имя члена семьи'))),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: canAdd
                  ? () async {
                      final v = nameCtl.text.trim();
                      if (v.isEmpty) return;
                      final next = [..._family, v];
                      await ProfileService.setFamily(next);
                      setState(() {
                        _family = next;
                        nameCtl.clear();
                      });
                    }
                  : null,
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Добавить'),
            ),
          ]),
          const SizedBox(height: 8),
          const Text('LUMI будет ежедневно интересоваться их самочувствием и напоминать о важном.'),
        ]),
      ),
    );
  }

  Widget _subscriptionCardFinal() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Подписки'),
          const SizedBox(height: 8),
          Text('Текущий план: ${_plan.toUpperCase()}'),
          const SizedBox(height: 8),
          _planTile('basic', 'Бесплатный — 0 ₸', 'До 5 членов семьи, базовый ИИ'),
          _planTile('vip', 'VIP — 2 490 ₸/мес', 'До 10 членов семьи, улучшенный ИИ (ChatGPT+Grok), приоритетные ответы, −5% на страхование*'),
          _planTile('premium', 'Premium — 4 990 ₸/мес', 'До 25 членов семьи, расширенный ИИ и анализ фото, приоритет x2, −10% на страхование*'),
          const SizedBox(height: 8),
          const Text('* цены и скидки демонстрационные; условия зависят от партнёров и региона'),
        ]),
      ),
    );
  }

  Widget _planTile(String id, String title, String subtitle) {
    return RadioListTile<String>(
      value: id,
      groupValue: _plan,
      onChanged: (v) async {
        if (v == null) return;
        await ProfileService.setPlan(v);
        setState(() => _plan = v);
        await _loadFamily();
      },
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      isThreeLine: true,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
