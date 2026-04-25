import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../../theme/motion.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';

/// 朱砂 (cinnabar) seal stamp button. On press it scales up briefly,
/// snaps back, and stamps a square red seal beneath the touch point.
/// Provides the "commit" gesture for new and edited notes.
class CinnabarSeal extends StatefulWidget {
  final String glyph;
  final Future<void> Function() onSealed;

  const CinnabarSeal({super.key, required this.glyph, required this.onSealed});

  @override
  State<CinnabarSeal> createState() => _CinnabarSealState();
}

class _CinnabarSealState extends State<CinnabarSeal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl =
      AnimationController(vsync: this, duration: Motion.med);

  Future<void> _press() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 18, amplitude: 130);
    }
    await _ctl.forward(from: 0);
    await widget.onSealed();
    if (!mounted) return;
    _ctl.reverse();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _press,
      child: AnimatedBuilder(
        animation: _ctl,
        builder: (_, child) {
          final t = _ctl.value;
          // Scale up then drop into a stamp.
          final scale = t < 0.4
              ? 1 + Curves.easeOut.transform(t / 0.4) * 0.18
              : 1.18 - Curves.easeIn.transform((t - 0.4) / 0.6) * 0.30;
          return Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: sin(t * pi) * 0.05,
              child: child,
            ),
          );
        },
        child: CustomPaint(
          painter: _SealPainter(),
          child: SizedBox(
            width: 64,
            height: 64,
            child: Center(
              child: Text(
                widget.glyph,
                style: AppType.brush(
                    size: 30, color: Palette.yueBai, letter: 0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SealPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = Random(13);
    final base = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    // Cinnabar fill with paper-mask noise (drawn as randomly omitted dots).
    canvas.drawRRect(
      RRect.fromRectAndRadius(base, const Radius.circular(6)),
      Paint()..color = Palette.zhuSha,
    );
    // Imperfect bite marks along the edge.
    final mask = Paint()..color = Palette.xuanZhi;
    for (int i = 0; i < 26; i++) {
      final x = base.left + r.nextDouble() * base.width;
      final y = r.nextBool() ? base.top - 1 : base.bottom + 1;
      canvas.drawCircle(Offset(x, y), 1.5 + r.nextDouble() * 1.6, mask);
    }
    // Inner border.
    canvas.drawRRect(
      RRect.fromRectAndRadius(base.deflate(4), const Radius.circular(4)),
      Paint()
        ..color = Palette.yueBai.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
