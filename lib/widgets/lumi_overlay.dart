import 'package:flutter/material.dart';
import 'lumi_widget.dart';
import 'lumi_alive.dart';
import '../lumi/lumi_brain.dart';

class LumiOverlayController extends ChangeNotifier {
  bool visible = true;
  Offset anchor = const Offset(0.88, 0.28); // more visible by default
  String? speech;
  LumiEmotion emotion = LumiEmotion.neutral;
  void Function(Offset to, {Duration duration, Curve curve})? _animator;
  bool wander = true;

  void setVisible(bool v) {
    visible = v;
    notifyListeners();
  }

  void setAnchor(Offset a) {
    anchor = a;
    notifyListeners();
  }

  void setSpeech(String? s) {
    speech = s;
    notifyListeners();
  }

  void setEmotion(LumiEmotion e) {
    emotion = e;
    notifyListeners();
  }

  void attachAnimator(
    void Function(Offset to, {Duration duration, Curve curve}) f,
  ) {
    _animator = f;
  }

  void animateTo(
    Offset to, {
    Duration duration = const Duration(milliseconds: 900),
    Curve curve = Curves.easeInOut,
  }) {
    final fn = _animator;
    if (fn != null) {
      fn(to, duration: duration, curve: curve);
    } else {
      setAnchor(to);
    }
  }
}

class GlobalLumiOverlay extends StatefulWidget {
  const GlobalLumiOverlay({super.key, required this.controller});
  final LumiOverlayController controller;

  @override
  State<GlobalLumiOverlay> createState() => _GlobalLumiOverlayState();
}

class _GlobalLumiOverlayState extends State<GlobalLumiOverlay>
    with SingleTickerProviderStateMixin {
  List<Offset>? _trail;
  Offset _gaze = Offset.zero;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
    widget.controller.attachAnimator(_animateTo);
    _startWander();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});
  void _animateTo(
    Offset to, {
    Duration duration = const Duration(milliseconds: 900),
    Curve curve = Curves.easeOutBack,
  }) {
    final begin = widget.controller.anchor;
    final anim = AnimationController(vsync: this, duration: duration);
    final tween = Tween<Offset>(
      begin: begin,
      end: to,
    ).animate(CurvedAnimation(parent: anim, curve: curve));
    tween.addListener(() {
      widget.controller.anchor = tween.value;
      setState(() {});
    });
    anim.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        anim.dispose();
      }
    });
    anim.forward();
  }

  void _startWander() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 12));
      if (!widget.controller.wander || !widget.controller.visible) continue;
      final randX = (0.15 + (0.7) * (DateTime.now().millisecond % 100) / 100);
      final randY = (0.2 + (0.6) * (DateTime.now().second % 60) / 60);
      final target = Offset(randX, randY);
      widget.controller.animateTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.visible) return const SizedBox.shrink();
    final size = MediaQuery.of(context).size;
    // Trail painter using recent anchors
    _trail ??= <Offset>[];
    final current = widget.controller.anchor;
    if (_trail!.isEmpty || _trail!.last != current) {
      _trail!.add(current);
      if (_trail!.length > 24) _trail!.removeAt(0);
    }
    final pos = Offset(
      size.width * widget.controller.anchor.dx - 90,
      size.height * widget.controller.anchor.dy - 90,
    );
    return Stack(
        children: [
          IgnorePointer(
            ignoring: true,
            child: Positioned.fill(
              child: CustomPaint(painter: _TrailPainter(_trail!)),
            ),
          ),
          Positioned(
            left: pos.dx.clamp(8, size.width - 188),
            top: pos.dy.clamp(
              8,
              size.height - 188 - MediaQuery.of(context).padding.bottom,
            ),
            child: GestureDetector(
            onTapDown: (d) {
              final size = MediaQuery.of(context).size;
              final g = d.globalPosition;
              final nx = (g.dx) / size.width;
              final ny = (g.dy) / size.height;
              widget.controller.animateTo(Offset(nx.clamp(0.0, 1.0), ny.clamp(0.0, 1.0)));
              LumiBrain.instance.onHomeOpen();
            },
            onPanUpdate: (d) {
              final nx = (pos.dx + d.delta.dx + 90) / size.width;
              final ny = (pos.dy + d.delta.dy + 90) / size.height;
              widget.controller.setAnchor(
                Offset(nx.clamp(0.0, 1.0), ny.clamp(0.0, 1.0)),
              );
            },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.controller.speech != null)
                    Container(
                      constraints: const BoxConstraints(maxWidth: 260),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(blurRadius: 10, color: Colors.black26),
                        ],
                      ),
                      child: Text(
                        widget.controller.speech!,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  MouseRegion(
                    onHover: (e) {
                      final center = Offset(pos.dx + 90, pos.dy + 90);
                      final d = e.position - center;
                      final nx = (d.dx / 90).clamp(-1.0, 1.0);
                      final ny = (d.dy / 90).clamp(-1.0, 1.0);
                      setState(() => _gaze = Offset(nx, ny));
                    },
                    onExit: (_) => setState(() => _gaze = Offset.zero),
                    child: LumiAlive(
                      emotion: widget.controller.emotion,
                      size: 180,
                      gaze: _gaze,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
  }
}

// Simple global access helper
class LumiOverlay {
  static LumiOverlayController? _controller;
  static void init(LumiOverlayController c) => _controller = c;
  static LumiOverlayController? get controller => _controller;
  static void set({
    LumiEmotion? emotion,
    String? speech,
    Offset? anchor,
    bool? visible,
  }) {
    final c = _controller;
    if (c == null) return;
    if (emotion != null) c.setEmotion(emotion);
    if (speech != null || speech == null) c.setSpeech(speech);
    if (anchor != null) c.setAnchor(anchor);
    if (visible != null) c.setVisible(visible);
  }
}

class _TrailPainter extends CustomPainter {
  final List<Offset> trail; // fractional positions 0..1
  _TrailPainter(this.trail);
  @override
  void paint(Canvas canvas, Size size) {
    if (trail.isEmpty) return;
    for (int i = 0; i < trail.length; i++) {
      final t = trail[i];
      final p = Offset(t.dx * size.width, t.dy * size.height);
      final alpha = (i + 1) / trail.length;
      final paint = Paint()
        ..color = Colors.cyanAccent.withValues(alpha: 0.15 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(p, 12 * alpha, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrailPainter oldDelegate) => true;
}
