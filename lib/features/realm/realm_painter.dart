import 'dart:math';

import 'package:flutter/material.dart';

import '../../rendering/ink/brush_stroke.dart';
import '../../theme/palette.dart';

/// Layered ink-wash mountains and sea. Four parallax bands:
///   0 — distant range (faint, far back)
///   1 — middle range (taller, more detail)
///   2 — near peaks (with pine accents)
///   3 — sea + foreground reeds
///
/// Tilt offset comes from `parallax` (Dart side feeds gyroscope here).
class RealmPainter extends CustomPainter {
  final double parallaxX;
  final double parallaxY;
  final double seedSalt;

  RealmPainter({
    required this.parallaxX,
    required this.parallaxY,
    this.seedSalt = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Far range — pale 黛青.
    _paintRange(canvas, size,
        baseY: h * 0.55,
        height: h * 0.18,
        peaks: 6,
        color: Palette.daiQing.withOpacity(0.42),
        seed: 11,
        parallax: 0.15);

    // Mid range — taller, dragon-tooth profile.
    _paintRange(canvas, size,
        baseY: h * 0.62,
        height: h * 0.22,
        peaks: 5,
        color: Palette.qingDai.withOpacity(0.7),
        seed: 23,
        parallax: 0.35);

    // Near range — with pine speckles.
    _paintRange(canvas, size,
        baseY: h * 0.72,
        height: h * 0.20,
        peaks: 4,
        color: Palette.moHei.withOpacity(0.78),
        seed: 47,
        parallax: 0.6,
        decorate: true);

    // Sea band.
    _paintSea(canvas, Rect.fromLTWH(0, h * 0.82, w, h * 0.18));

    // Foreground reeds.
    _paintReeds(canvas, size, parallax: 1.2);
  }

  void _paintRange(
    Canvas c,
    Size size, {
    required double baseY,
    required double height,
    required int peaks,
    required Color color,
    required int seed,
    required double parallax,
    bool decorate = false,
  }) {
    final r = Random((seed + (seedSalt * 1000).round()).hashCode);
    final w = size.width;
    final dx = parallaxX * 30 * parallax;
    final dy = parallaxY * 12 * parallax;
    final segW = w / peaks;
    for (int i = 0; i < peaks; i++) {
      final apex = Offset(
        i * segW + segW * (0.3 + r.nextDouble() * 0.5) + dx,
        baseY + dy - height * (0.6 + r.nextDouble() * 0.4),
      );
      final mtnW = segW * (1.1 + r.nextDouble() * 0.6);
      final mtnH = height * (0.8 + r.nextDouble() * 0.5);
      final path = BrushStrokePainter.mountain(
        apex: apex,
        width: mtnW,
        height: mtnH,
        jaggedness: 0.10,
        seed: i + seed,
      );
      c.drawPath(path, Paint()..color = color);
      // Highlight ridge with a darker brushstroke.
      final ridge = Path()
        ..moveTo(apex.dx - mtnW / 2, apex.dy + mtnH)
        ..quadraticBezierTo(apex.dx, apex.dy - mtnH * 0.05,
            apex.dx + mtnW / 2, apex.dy + mtnH);
      BrushStrokePainter.stroke(c, ridge,
          color: Palette.moHei,
          width: 2.4,
          opacity: 0.32,
          tipNarrow: 0.05);

      if (decorate) {
        // Pine speckles on the upper third.
        final pineCount = 4 + r.nextInt(4);
        for (int j = 0; j < pineCount; j++) {
          final px = apex.dx + (r.nextDouble() - 0.5) * mtnW * 0.7;
          final py = apex.dy + r.nextDouble() * mtnH * 0.55;
          _drawPine(c, Offset(px, py), 6 + r.nextDouble() * 6);
        }
      }
    }
  }

  void _drawPine(Canvas c, Offset o, double s) {
    final paint = Paint()
      ..color = Palette.moHei.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    // Trunk
    c.drawRect(
        Rect.fromCenter(
            center: o.translate(0, s * 0.5), width: s * 0.18, height: s * 0.6),
        paint);
    // Three-tier crown
    for (int i = 0; i < 3; i++) {
      final yo = o.dy + i * s * 0.3 - s * 0.4;
      final ww = s * (0.9 - i * 0.18);
      final p = Path()
        ..moveTo(o.dx, yo - s * 0.55)
        ..lineTo(o.dx - ww * 0.5, yo)
        ..lineTo(o.dx + ww * 0.5, yo)
        ..close();
      c.drawPath(p, paint);
    }
  }

  void _paintSea(Canvas c, Rect r) {
    // Base wash
    final grad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Palette.daiQing.withOpacity(0.55),
        Palette.qingDai.withOpacity(0.85),
      ],
    );
    c.drawRect(r, Paint()..shader = grad.createShader(r));
    // Ripple lines.
    final paint = Paint()
      ..color = Palette.yueBai.withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final rng = Random(7);
    for (double y = r.top + 6; y < r.bottom; y += 8 + rng.nextDouble() * 6) {
      final p = Path();
      p.moveTo(r.left, y);
      for (double x = r.left; x <= r.right; x += 14) {
        p.lineTo(x, y + sin(x * 0.05 + y * 0.1) * 1.4);
      }
      c.drawPath(p, paint);
    }
  }

  void _paintReeds(Canvas c, Size size, {required double parallax}) {
    final r = Random(101);
    final paint = Paint()
      ..color = Palette.moHei.withOpacity(0.72)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6;
    final dx = parallaxX * 30 * parallax;
    for (int i = 0; i < 22; i++) {
      final x = i * size.width / 22 + r.nextDouble() * 12 + dx;
      final h = 18 + r.nextDouble() * 22;
      final lean = (r.nextDouble() - 0.5) * 6;
      final p = Path()
        ..moveTo(x, size.height)
        ..quadraticBezierTo(x + lean, size.height - h * 0.6, x + lean * 1.4,
            size.height - h);
      c.drawPath(p, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RealmPainter old) =>
      old.parallaxX != parallaxX ||
      old.parallaxY != parallaxY ||
      old.seedSalt != seedSalt;
}
