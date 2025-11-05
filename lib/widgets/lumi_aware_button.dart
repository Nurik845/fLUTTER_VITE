import 'package:flutter/material.dart';
import 'lumi_overlay.dart';
import 'lumi_widget.dart';

class LumiAwareButton extends StatelessWidget {
  const LumiAwareButton({super.key, required this.child, required this.onPressed, this.emotionOnTap});
  final Widget child; final VoidCallback onPressed; final LumiEmotion? emotionOnTap;
  @override
  Widget build(BuildContext context) {
    final key = GlobalKey();
    return Builder(builder: (ctx) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          final rb = key.currentContext?.findRenderObject() as RenderBox?;
          final offset = rb?.localToGlobal(Offset.zero);
          if (rb != null && offset != null) {
            final size = MediaQuery.of(ctx).size;
            final center = offset + rb.size.center(Offset.zero);
            final anchor = Offset(center.dx / size.width, center.dy / size.height);
            LumiOverlay.set(anchor: anchor);
          }
          if (emotionOnTap != null) {
            LumiOverlay.set(emotion: emotionOnTap);
          }
        },
        onTap: onPressed,
        child: Container(key: key, child: child),
      );
    });
  }
}

