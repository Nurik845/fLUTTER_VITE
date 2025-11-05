import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'lumi_widget.dart';

/// Procedural, fully animated Lumi made of light.
/// - Breathes and floats
/// - Blinks and looks towards [gaze]
/// - Pulses when [speaking] or in excited/anxious states
/// - Color palette changes per [emotion]
class LumiAlive extends StatefulWidget {
  const LumiAlive({
    super.key,
    required this.emotion,
    this.size = 180,
    this.gaze,
  });

  final LumiEmotion emotion;
  final double size;
  /// Normalized gaze target relative to the center (−1..1)
  final Offset? gaze;

  @override
  State<LumiAlive> createState() => _LumiAliveState();
}

class _LumiAliveState extends State<LumiAlive> with TickerProviderStateMixin {
  late final AnimationController t;
  late final AnimationController blink;

  @override
  void initState() {
    super.initState();
    t = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    blink = AnimationController(vsync: this, duration: const Duration(milliseconds: 240));
    _scheduleBlink();
  }

  void _scheduleBlink() async {
    while (mounted) {
      await Future.delayed(Duration(milliseconds: 1800 + math.Random().nextInt(2200)));
      if (!mounted) return;
      await blink.forward();
      await blink.reverse();
    }
  }

  @override
  void dispose() {
    t.dispose();
    blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([t, blink]),
      builder: (context, _) {
        final breath = 0.06 + 0.04 * math.sin(t.value * math.pi * 2);
        final speakPulse = _speaking ? (0.5 + 0.5 * math.sin(t.value * math.pi * 16)) : 0.0;
        final floatY = 6 * math.sin(t.value * math.pi * 2);
        final params = _palette(widget.emotion);
        final gaze = widget.gaze ?? Offset.zero;
        final blinkAmt = (blink.value > 0.5) ? (1 - blink.value) * 2 : blink.value * 2; // 0..1..0
        return Transform.translate(
          offset: Offset(0, floatY),
          child: CustomPaint(
            painter: _LumiPainter(
              size: widget.size,
              base: params.base,
              aura: params.aura,
              ring: params.ring,
              mouth: params.mouth,
              emotion: widget.emotion,
              breath: breath,
              speakPulse: speakPulse,
              gaze: gaze,
              blink: blinkAmt,
            ),
            size: Size(widget.size, widget.size),
          ),
        );
      },
    );
  }

  bool get _speaking => widget.emotion == LumiEmotion.speaking || widget.emotion == LumiEmotion.excited || widget.emotion == LumiEmotion.anxious;

  _Palette _palette(LumiEmotion e) {
    switch (e) {
      case LumiEmotion.happy:
        return _Palette(base: Colors.cyanAccent, aura: Colors.white, ring: Colors.amberAccent, mouth: Colors.white);
      case LumiEmotion.excited:
        return _Palette(base: Colors.amberAccent, aura: Colors.white, ring: Colors.deepOrangeAccent, mouth: Colors.white);
      case LumiEmotion.sad:
        return _Palette(base: Colors.lightBlue.shade200, aura: Colors.white, ring: Colors.blueGrey, mouth: Colors.white70);
      case LumiEmotion.curious:
        return _Palette(base: Colors.lightBlueAccent, aura: Colors.white, ring: Colors.tealAccent, mouth: Colors.white);
      case LumiEmotion.anxious:
        return _Palette(base: Colors.redAccent.shade100, aura: Colors.white, ring: Colors.redAccent, mouth: Colors.white);
      case LumiEmotion.care:
        return _Palette(base: Colors.pinkAccent.shade100, aura: Colors.white, ring: Colors.pinkAccent, mouth: Colors.white);
      case LumiEmotion.sleepy:
        return _Palette(base: Colors.blueGrey.shade300, aura: Colors.white70, ring: Colors.blueGrey.shade200, mouth: Colors.white70);
      case LumiEmotion.listening:
        return _Palette(base: Colors.cyanAccent.shade100, aura: Colors.white, ring: Colors.lightBlueAccent, mouth: Colors.white);
      case LumiEmotion.speaking:
        return _Palette(base: Colors.amberAccent.shade100, aura: Colors.white, ring: Colors.orangeAccent, mouth: Colors.white);
      case LumiEmotion.pointing:
        return _Palette(base: Colors.tealAccent, aura: Colors.white, ring: Colors.teal, mouth: Colors.white);
      default:
        return _Palette(base: Colors.cyanAccent, aura: Colors.white, ring: Colors.cyan, mouth: Colors.white);
    }
  }
}

class _Palette {
  final Color base, aura, ring, mouth;
  _Palette({required this.base, required this.aura, required this.ring, required this.mouth});
}

class _LumiPainter extends CustomPainter {
  final double size;
  final Color base, aura, ring, mouth;
  final LumiEmotion emotion;
  final double breath; // 0..~0.1
  final double speakPulse; // 0..1
  final Offset gaze; // -1..1
  final double blink; // 0..1..0

  _LumiPainter({
    required this.size,
    required this.base,
    required this.aura,
    required this.ring,
    required this.mouth,
    required this.emotion,
    required this.breath,
    required this.speakPulse,
    required this.gaze,
    required this.blink,
  });

  @override
  void paint(Canvas canvas, Size s) {
    final center = s.center(Offset.zero);
    final r = s.shortestSide / 2;

    // Outer aura glow
    final glow = Paint()
      ..shader = RadialGradient(colors: [base.withValues(alpha: 0.85), base.withValues(alpha: 0.0)], stops: const [0.35, 1]).createShader(Rect.fromCircle(center: center, radius: r * (1.5 + breath * 2)))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(center, r * (1.25 + breath), glow);

    // Core body gradient
    final body = Paint()
      ..shader = RadialGradient(colors: [aura.withValues(alpha: 0.95), base.withValues(alpha: 0.85), base.withValues(alpha: 0.3)], stops: const [0.0, 0.55, 1.0]).createShader(Rect.fromCircle(center: center, radius: r * (1 + breath)));
    canvas.drawCircle(center, r * (0.94 + breath), body);

    // Pulse ring
    final ringR = r * (0.95 + breath + speakPulse * 0.05);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 + speakPulse * 2
      ..color = ring.withValues(alpha: 0.7 - 0.5 * (1 - speakPulse));
    canvas.drawCircle(center, ringR, ringPaint);

    // Sparkles
    final n = 20;
    for (int i = 0; i < n; i++) {
      final a = (i / n) * math.pi * 2 + speakPulse * 0.2;
      final rr = ringR * (0.9 + 0.08 * math.sin(a * 4));
      final p = Offset(center.dx + rr * math.cos(a), center.dy + rr * math.sin(a));
      final sp = Paint()
        ..color = aura.withValues(alpha: 0.08 + 0.06 * math.sin(a * 6))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(p, 2.2, sp);
    }

    // Eyes with blink and gaze
    final eyeOffset = Offset(24 * gaze.dx, 6 * gaze.dy);
    final eyeSize = Size(16, 10 * (1 - 0.85 * blink));
    final leftEye = center + Offset(-size * 0.18, -size * 0.05) + eyeOffset;
    final rightEye = center + Offset(size * 0.18, -size * 0.05) + eyeOffset;
    final eyePaint = Paint()..color = Colors.white.withValues(alpha: 0.95);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: leftEye, width: eyeSize.width, height: eyeSize.height), const Radius.circular(12)), eyePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: rightEye, width: eyeSize.width, height: eyeSize.height), const Radius.circular(12)), eyePaint);

    // Mouth shape changes by emotion
    final mouthW = 42.0 + 10 * speakPulse;
    final mouthH = switch (emotion) {
      LumiEmotion.happy => 10.0 + 4 * speakPulse,
      LumiEmotion.excited => 12.0 + 6 * speakPulse,
      LumiEmotion.sad => 6.0,
      LumiEmotion.sleepy => 4.0,
      LumiEmotion.anxious => 8.0 + 8 * speakPulse,
      _ => 6.0 + 2 * speakPulse,
    };
    final mouthCenter = center + Offset(0, size * 0.16);
    final mouthPaint = Paint()..color = mouth.withValues(alpha: 0.95);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: mouthCenter, width: mouthW, height: mouthH),
        const Radius.circular(12),
      ),
      mouthPaint,
    );

    // Subtle arms
    final armPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final lv = center + Offset(-r * 0.6, 0.0);
    final rv = center + Offset(r * 0.6, 0.0);
    final lc = center + Offset(-r * 0.5, -r * (emotion == LumiEmotion.happy || emotion == LumiEmotion.excited ? 0.25 : 0.05));
    final rc = center + Offset(r * 0.5, -r * (emotion == LumiEmotion.happy || emotion == LumiEmotion.excited ? 0.25 : 0.05));
    final lp = Path()..moveTo(lv.dx, lv.dy)..quadraticBezierTo(lc.dx, lc.dy, center.dx - r * 0.25, center.dy);
    final rp = Path()..moveTo(rv.dx, rv.dy)..quadraticBezierTo(rc.dx, rc.dy, center.dx + r * 0.25, center.dy);
    canvas.drawPath(lp, armPaint);
    canvas.drawPath(rp, armPaint);
  }

  @override
  bool shouldRepaint(covariant _LumiPainter oldDelegate) =>
      oldDelegate.base != base ||
      oldDelegate.emotion != emotion ||
      oldDelegate.breath != breath ||
      oldDelegate.speakPulse != speakPulse ||
      oldDelegate.gaze != gaze ||
      oldDelegate.blink != blink;
}

