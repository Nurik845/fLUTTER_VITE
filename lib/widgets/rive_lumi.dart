import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'lumi_widget.dart';

class RiveLumi extends StatefulWidget {
  const RiveLumi({super.key, required this.emotion, this.size = 180});
  final LumiEmotion emotion;
  final double size;
  @override
  State<RiveLumi> createState() => _RiveLumiState();
}

class _RiveLumiState extends State<RiveLumi> {
  Artboard? _art;
  StateMachineController? _ctrl;
  final Map<String, SMIInput<dynamic>> _inputs = {};
  Object? _err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final file = await RiveFile.asset('assets/lumi.riv');
      final art = file.mainArtboard;
      StateMachineController? ctrl;
      for (final sm in art.stateMachines) {
        ctrl = StateMachineController.fromArtboard(art, sm.name);
        if (ctrl != null) {
          break;
        }
      }
      if (ctrl != null) {
        art.addController(ctrl);
        _ctrl = ctrl;
        for (final i in ctrl.inputs) {
          _inputs[i.name] = i;
        }
      }
      setState(() {
        _art = art;
      });
      _applyEmotion(widget.emotion);
    } catch (e) {
      setState(() {
        _err = e;
      });
    }
  }

  void _applyEmotion(LumiEmotion e) {
    if (_ctrl == null) return;
    // Try boolean inputs first
    for (final name in [
      'happy',
      'excited',
      'sad',
      'listening',
      'speaking',
      'curious',
      'anxious',
      'care',
      'sleepy',
      'neutral',
      'pointing',
    ]) {
      final i = _inputs[name];
      if (i is SMIBool) i.value = false;
    }
    String on;
    switch (e) {
      case LumiEmotion.happy:
        on = 'happy';
        break;
      case LumiEmotion.excited:
        on = 'excited';
        break;
      case LumiEmotion.sad:
        on = 'sad';
        break;
      case LumiEmotion.listening:
        on = 'listening';
        break;
      case LumiEmotion.speaking:
        on = 'speaking';
        break;
      case LumiEmotion.curious:
        on = 'curious';
        break;
      case LumiEmotion.anxious:
        on = 'anxious';
        break;
      case LumiEmotion.care:
        on = 'care';
        break;
      case LumiEmotion.sleepy:
        on = 'sleepy';
        break;
      case LumiEmotion.pointing:
        on = 'pointing';
        break;
      default:
        on = 'neutral';
    }
    final b = _inputs[on];
    if (b is SMIBool) b.value = true;
    final idx = _inputs['emotionIndex'];
    if (idx is SMINumber) idx.value = e.index.toDouble();
  }

  @override
  void didUpdateWidget(covariant RiveLumi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emotion != widget.emotion) {
      _applyEmotion(widget.emotion);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_err != null) return const SizedBox.shrink();
    if (_art == null) return const SizedBox(height: 180, width: 180);
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: Rive(artboard: _art!),
    );
  }
}
