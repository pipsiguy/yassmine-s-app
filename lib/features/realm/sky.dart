import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/palette.dart';
import '../../utils/lunar.dart';

/// Full-screen sky painter — gradient bands by hour, plus sun/moon disc.
/// The moon is rendered with a real-ish phase shadow (see [lunarPhase]).
class Sky extends StatelessWidget {
  final DateTime now;
  const Sky({super.key, required this.now});

  @override
  Widget build(BuildContext context) {
    final band = SkyBand.now(now);
    final colors = _colorsFor(band);
    return CustomPaint(
      painter: _SkyPainter(colors: colors, now: now, band: band),
      size: Size.infinite,
    );
  }

  static List<Color> _colorsFor(SkyBand b) {
    final from = switch (b.band) {
      0 => Palette.skyDawn,
      1 => Palette.skyDay,
      2 => Palette.skyDusk,
      _ => Palette.skyNight,
    };
    final to = switch (b.band) {
      0 => Palette.skyDay,
      1 => Palette.skyDusk,
      2 => Palette.skyNight,
      _ => Palette.skyDawn,
    };
    return [
      Color.lerp(from[0], to[0], b.bandT)!,
      Color.lerp(from[1], to[1], b.bandT)!,
      Color.lerp(from[2], to[2], b.bandT)!,
    ];
  }
}

class _SkyPainter extends CustomPainter {
  final List<Color> colors;
  final DateTime now;
  final SkyBand band;

  _SkyPainter({required this.colors, required this.now, required this.band});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final grad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
      stops: const [0.0, 0.55, 1.0],
    );
    canvas.drawRect(rect, Paint()..shader = grad.createShader(rect));

    // Sun by day, moon by dusk/night.
    final isNight = band.band == 3 || (band.band == 2 && band.bandT > 0.4);
    final h = now.hour + now.minute / 60.0;
    // Map "interesting" hours to a horizontal arc across the sky.
    final t = ((h - 5) / 14).clamp(0.0, 1.0); // 5am..7pm sun arc
    final cx = size.width * (0.15 + 0.7 * t);
    final cy = size.height * (0.42 - math.sin(math.pi * t) * 0.18);

    if (!isNight) {
      // Sun — soft, warm.
      _drawDisc(canvas, Offset(cx, cy), 36, const Color(0xFFEBD2A0),
          glowColor: const Color(0x66FFCB7B));
    } else {
      // Moon — phase-aware disc.
      final phase = lunarPhase(now);
      _drawMoon(canvas, Offset(size.width * 0.78, size.height * 0.18), 32, phase);
    }
    // Stars at night.
    if (band.band == 3) {
      final p = Paint()..color = Colors.white.withOpacity(0.7);
      final r = math.Random(42);
      for (int i = 0; i < 60; i++) {
        canvas.drawCircle(
          Offset(r.nextDouble() * size.width, r.nextDouble() * size.height * 0.6),
          r.nextDouble() * 0.9 + 0.2,
          p,
        );
      }
    }
  }

  void _drawDisc(Canvas c, Offset o, double r, Color core,
      {required Color glowColor}) {
    c.drawCircle(
      o,
      r * 2.4,
      Paint()
        ..color = glowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
    c.drawCircle(o, r, Paint()..color = core);
  }

  void _drawMoon(Canvas c, Offset o, double r, double phase) {
    // Glow
    c.drawCircle(
      o,
      r * 3,
      Paint()
        ..color = Palette.yueBai.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26),
    );
    // Full disc
    c.drawCircle(o, r, Paint()..color = Palette.yueBai);
    // Shadow (simple — offset the dark side, clip to disc).
    final dx = (phase < 0.5)
        ? (1 - phase * 2) * r // waxing
        : -((phase - 0.5) * 2) * r; // waning
    final shadow = Path()
      ..addOval(Rect.fromCircle(center: Offset(o.dx + dx, o.dy), radius: r));
    c.save();
    c.clipPath(Path()..addOval(Rect.fromCircle(center: o, radius: r)));
    c.drawPath(shadow, Paint()..color = Palette.yeKong.withOpacity(0.92));
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) =>
      old.now != now || old.band.band != band.band;
}
