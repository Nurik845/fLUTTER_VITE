import 'package:flutter/material.dart';
import '../widgets/lumi_overlay.dart';
import '../widgets/lumi_widget.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});
  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  bool sportMode = false;
  double height = 175; // cm
  double weight = 75; // kg
  int age = 25;
  String sex = 'male';
  String goal = 'keep'; // lose/keep/gain
  final allergies = <String>{};

  double get _bmr {
    // Mifflin–St Jeor
    if (sex == 'male') {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
  }

  double get _targetCal {
    final base = _bmr * 1.25; // light activity
    switch (goal) {
      case 'lose':
        return base - 400;
      case 'gain':
        return base + 300;
      default:
        return base;
    }
  }

  Map<String, int> get _macros {
    final cal = _targetCal;
    final protein = (weight * 1.8).round();
    final fat = (cal * 0.25 / 9).round();
    final carbs = ((cal - protein * 4 - fat * 9) / 4).round();
    return {'kcal': cal.round(), 'P': protein, 'F': fat, 'C': carbs};
  }

  @override
  Widget build(BuildContext context) {
    final m = _macros;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          value: sportMode,
          title: const Text('Sport mode'),
          subtitle: const Text('LUMI cheers you with voice and animations'),
          onChanged: (v) {
            setState(() => sportMode = v);
            LumiOverlay.set(
              emotion: v ? LumiEmotion.excited : LumiEmotion.neutral,
              speech: v ? 'Поехали! Режим спорта включён.' : null,
            );
          },
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Your data', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(children: [
                Expanded(child: _numTile('Height (cm)', height, 120, 220, (v) => setState(() => height = v))),
                const SizedBox(width: 8),
                Expanded(child: _numTile('Weight (kg)', weight, 35, 180, (v) => setState(() => weight = v))),
              ]),
              Row(children: [
                Expanded(child: _intTile('Age', age, (v) => setState(() => age = v))),
                const SizedBox(width: 8),
                Expanded(child: _segTile('Sex', sex, ['male','female'], (v)=> setState(()=> sex = v))),
              ]),
              _segTile('Goal', goal, ['lose','keep','gain'], (v)=> setState(()=> goal = v)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                _chip('Nuts', 'nuts'),
                _chip('Dairy', 'dairy'),
                _chip('Gluten', 'gluten'),
                _chip('Seafood', 'seafood'),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Daily plan', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Calories: ${m['kcal']}   P: ${m['P']}g   F: ${m['F']}g   C: ${m['C']}g'),
              const SizedBox(height: 6),
              const Text('Workout: 20–30 min (walk/yoga or light cardio)'),
              const Text('Steps: 8,000–10,000'),
              Text('Allergies: ${allergies.isEmpty ? 'None' : allergies.join(', ')}'),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _numTile(String title, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title),
      Slider(min: min, max: max, value: value.clamp(min, max), onChanged: onChanged),
      Text(value.toStringAsFixed(0)),
    ]);
  }

  Widget _intTile(String title, int value, ValueChanged<int> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title),
      Slider(min: 10, max: 80, value: value.toDouble(), onChanged: (v)=> onChanged(v.round())),
      Text('$value'),
    ]);
  }

  Widget _segTile(String title, String selected, List<String> values, ValueChanged<String> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title),
      const SizedBox(height: 4),
      SegmentedButton<String>(
        segments: values.map((v)=> ButtonSegment(value: v, label: Text(v))).toList(),
        selected: {selected},
        onSelectionChanged: (s)=> onChanged(s.first),
      ),
    ]);
  }

  Widget _chip(String label, String keyName) {
    final sel = allergies.contains(keyName);
    return FilterChip(
      label: Text(label),
      selected: sel,
      onSelected: (v) => setState(() { if (v) { allergies.add(keyName); } else { allergies.remove(keyName); } }),
    );
  }
}

