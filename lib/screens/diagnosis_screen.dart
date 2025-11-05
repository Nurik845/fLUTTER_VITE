import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/localization.dart';
import '../services/diagnosis_service.dart';
import '../services/stt_service.dart';
import '../widgets/lumi_overlay.dart';
import '../widgets/lumi_widget.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});
  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  File? _image;
  DiagnosisResult? _result;
  bool _busy = false;
  String _heard = '';
  final Set<String> _allergies = {};
  final Set<String> _conditions = {};

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.camera, maxWidth: 1200);
    if (x != null) {
      setState(() { _image = File(x.path); _result = null; });
      await _runImage();
    }
  }

  Future<void> _runImage() async {
    setState(() => _busy = true);
    _result = await DiagnosisService.fromImage(
      _image!,
      lang: Localizations.maybeLocaleOf(context)?.languageCode ?? 'en',
    );
    setState(() => _busy = false);
    if (_result != null) {
      LumiOverlay.set(
        emotion: _result!.confidence >= 0.75 ? LumiEmotion.pointing : LumiEmotion.neutral,
        speech: _result!.label,
      );
    }
  }

  Future<void> _startVoice() async {
    await SttService.instance.start(
      localeId: (Localizations.maybeLocaleOf(context)?.toLanguageTag() ?? 'en-US').replaceAll('-', '_'),
      onResult: (text, finalR) async {
        setState(() => _heard = text);
        if (finalR) {
          setState(() => _busy = true);
          _result = await DiagnosisService.fromText(text, lang: Localizations.maybeLocaleOf(context)?.languageCode ?? 'en');
          setState(() => _busy = false);
          if (_result != null) {
            LumiOverlay.set(
              emotion: _result!.confidence >= 0.75 ? LumiEmotion.pointing : LumiEmotion.neutral,
              speech: _result!.label,
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Контекст (для рекомендаций):'),
              const SizedBox(height: 6),
              Wrap(spacing: 8, children: [
                FilterChip(label: const Text('Аллергия на лекарства'), selected: _allergies.contains('drugs'), onSelected: (v)=> setState(()=> v ? _allergies.add('drugs') : _allergies.remove('drugs'))),
                FilterChip(label: const Text('Астма'), selected: _conditions.contains('asthma'), onSelected: (v)=> setState(()=> v ? _conditions.add('asthma') : _conditions.remove('asthma'))),
                FilterChip(label: const Text('Диабет'), selected: _conditions.contains('diabetes'), onSelected: (v)=> setState(()=> v ? _conditions.add('diabetes') : _conditions.remove('diabetes'))),
                FilterChip(label: const Text('Антикоагулянты'), selected: _conditions.contains('anticoag'), onSelected: (v)=> setState(()=> v ? _conditions.add('anticoag') : _conditions.remove('anticoag'))),
              ]),
            ]),
          ),
        ),
        Row(children: [
          Expanded(child: FilledButton.icon(onPressed: _busy ? null : _pickImage, icon: const Icon(Icons.camera_alt), label: Text(l.pickPhoto))),
          const SizedBox(width: 12),
          Expanded(child: OutlinedButton.icon(onPressed: _busy ? null : _startVoice, icon: const Icon(Icons.mic), label: Text(l.speakSymptoms))),
        ]),
        const SizedBox(height: 16),
        if (_image != null) ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_image!)),
        if (_heard.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8.0), child: Text('"$_heard"', textAlign: TextAlign.center)),
        const SizedBox(height: 16),
        if (_busy) const Center(child: CircularProgressIndicator()),
        if (_result != null)
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.result, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('${_result!.label} — ${(100 * _result!.confidence).toStringAsFixed(0)}%'),
                if (_allergies.isNotEmpty || _conditions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Учет факторов: ${[..._allergies, ..._conditions].join(', ')}'),
                  const Text('Избегайте препаратов при известной аллергии. При антикоагулянтах — контролируйте кровотечение дольше.'),
                ],
                const SizedBox(height: 8),
                const Text('Не является медицинским диагнозом. Для демонстрации.'),
              ]),
            ),
          ),
      ]),
    );
  }
}

