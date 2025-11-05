import 'dart:math' as math;
import 'package:flutter/material.dart';

enum LumiEmotion { neutral, happy, excited, sad, listening, speaking, pointing, curious, anxious, care, sleepy }

class LumiWidget extends StatefulWidget {
  final bool speaking;
  final VoidCallback? onTap;
  final double size;
  final LumiEmotion emotion;
  const LumiWidget({
    super.key,
    this.speaking = false,
    this.onTap,
    this.size = 180,
    this.emotion = LumiEmotion.neutral,
  });

  @override
  State<LumiWidget> createState() => _LumiWidgetState();
}

class _LumiWidgetState extends State<LumiWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blink;
  late Animation<Offset> _float;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _blink = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 85),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
    ]).animate(_controller);
    _float = TweenSequence<Offset>([
      TweenSequenceItem(tween: Tween(begin: const Offset(-0.2, -0.1), end: const Offset(0.2, 0.1)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: const Offset(0.2, 0.1), end: const Offset(-0.2, 0.05)), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _baseColor();
    final glow = (widget.speaking || widget.emotion == LumiEmotion.excited) ? 36.0 : 20.0;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FractionalTranslation(
          translation: _float.value * 0.2,
          child: GestureDetector(
            onTap: widget.onTap,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          baseColor.withValues(alpha: 0.9),
                          baseColor.withValues(alpha: 0.2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(color: baseColor.withValues(alpha: 0.6), blurRadius: glow, spreadRadius: 8),
                      ],
                    ),
                  ),
                  // Arms
                  Positioned.fill(child: CustomPaint(painter: _ArmsPainter(emotion: widget.emotion, progress: _controller.value))),
                  // Eyes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _eye(_blink.value),
                      SizedBox(width: widget.size * 0.13),
                      _eye(_blink.value),
                    ],
                  ),
                  // Mouth / expression
                  Positioned(
                    bottom: widget.size * 0.27,
                    child: _mouth(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _baseColor() {
    switch (widget.emotion) {
      case LumiEmotion.happy:
        return Colors.cyanAccent;
      case LumiEmotion.excited:
        return Colors.amberAccent;
      case LumiEmotion.sad:
        return Colors.lightBlueAccent;
      case LumiEmotion.curious:
        return Colors.lightBlueAccent.shade100;
      case LumiEmotion.anxious:
        return Colors.redAccent.shade100;
      case LumiEmotion.care:
        return Colors.pinkAccent.shade100;
      case LumiEmotion.sleepy:
        return Colors.blueGrey.shade200;
      case LumiEmotion.listening:
        return Colors.cyanAccent.shade100;
      case LumiEmotion.speaking:
        return Colors.amberAccent.shade100;
      case LumiEmotion.pointing:
        return Colors.tealAccent;
      default:
        return Colors.cyanAccent;
    }
  }

  Widget _mouth() {
    final v = math.sin(_controller.value * math.pi * 2);
    switch (widget.emotion) {
      case LumiEmotion.happy:
        return Icon(Icons.emoji_emotions, color: Colors.white.withValues(alpha: 0.9), size: widget.size * 0.12);
      case LumiEmotion.excited:
        return Container(
          width: widget.size * (0.22 + 0.06 * v.abs()),
          height: widget.size * 0.04,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(12)),
        );
      case LumiEmotion.sad:
        return Transform.rotate(
          angle: math.pi,
          child: Icon(Icons.architecture, color: Colors.white.withValues(alpha: 0.8), size: widget.size * 0.09),
        );
      case LumiEmotion.listening:
        return Icon(Icons.dehaze, color: Colors.white.withValues(alpha: 0.8), size: widget.size * 0.08);
      case LumiEmotion.speaking:
        return Container(
          width: widget.size * (0.20 + 0.08 * v.abs()),
          height: widget.size * 0.045,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(8)),
        );
      case LumiEmotion.pointing:
        return Icon(Icons.more_horiz, color: Colors.white.withValues(alpha: 0.8), size: widget.size * 0.1);
      default:
        return Container(
          width: widget.size * 0.2,
          height: widget.size * 0.035,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(8)),
        );
    }
  }

  Widget _eye(double open) {
    final double h = (widget.emotion == LumiEmotion.happy) ? 12 : 20 * open.clamp(0.08, 1.0);
    return Container(
      width: 20,
      height: h,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _ArmsPainter extends CustomPainter {
  final LumiEmotion emotion;
  final double progress;
  _ArmsPainter({required this.emotion, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.45;

    // Left arm
    final leftStart = center + Offset(-r * 0.7, 0);
    final rightStart = center + Offset(r * 0.7, 0);

    Offset leftEnd = leftStart + Offset(-r * 0.5, r * 0.1 * math.sin(progress * math.pi * 2));
    Offset rightEnd = rightStart + Offset(r * 0.5, r * 0.1 * math.cos(progress * math.pi * 2));

    if (emotion == LumiEmotion.happy || emotion == LumiEmotion.excited) {
      leftEnd = leftStart + Offset(-r * 0.2, -r * 0.4);
      rightEnd = rightStart + Offset(r * 0.2, -r * 0.4);
    } else if (emotion == LumiEmotion.pointing) {
      leftEnd = leftStart + Offset(-r * 0.2, -r * 0.1);
      rightEnd = rightStart + Offset(r * 0.5, -r * 0.2);
    } else if (emotion == LumiEmotion.sad) {
      leftEnd = leftStart + Offset(-r * 0.2, r * 0.25);
      rightEnd = rightStart + Offset(r * 0.2, r * 0.25);
    }

    canvas.drawLine(leftStart, leftEnd, paint);
    canvas.drawLine(rightStart, rightEnd, paint);

    if (emotion == LumiEmotion.pointing) {
      final hand = rightEnd;
      final arrow = Path()
        ..moveTo(hand.dx + 6, hand.dy)
        ..lineTo(hand.dx + 18, hand.dy - 8)
        ..moveTo(hand.dx + 6, hand.dy)
        ..lineTo(hand.dx + 18, hand.dy + 8);
      canvas.drawPath(arrow, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArmsPainter oldDelegate) =>
      oldDelegate.emotion != emotion || oldDelegate.progress != progress;
}
