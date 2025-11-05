import 'package:flutter/material.dart';
import '../l10n/localization.dart';
import '../services/emergency_service.dart';
import '../widgets/lumi_overlay.dart';
import '../widgets/lumi_widget.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final _controller = TextEditingController(text: '112');
  bool _busy = false;

  Future<void> _wrap(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: l.enterPhone,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy
                ? null
                : () => _wrap(() async {
                      LumiOverlay.set(emotion: LumiEmotion.excited, speech: 'Calling 103...');
                      await EmergencyService.callNumber('103');
                    }),
            icon: const Icon(Icons.local_hospital),
            label: Text(l.call103),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _busy
                ? null
                : () => _wrap(() async {
                      LumiOverlay.set(emotion: LumiEmotion.excited, speech: 'Calling 112...');
                      await EmergencyService.callNumber('112');
                    }),
            icon: const Icon(Icons.sos),
            label: Text(l.call112),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy
                ? null
                : () => _wrap(() async {
                      LumiOverlay.set(emotion: LumiEmotion.pointing, speech: 'Sending SMS + GPS');
                      await EmergencyService.smsWithGps(_controller.text.trim());
                    }),
            icon: const Icon(Icons.sms),
            label: Text(l.smsGps),
          ),
          const SizedBox(height: 16),
          Text('Smart 911 (auto-detect region) — demo via dialer/SMS'),
        ],
      ),
    );
  }
}
