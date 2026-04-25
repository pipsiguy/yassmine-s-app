import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/guardian.dart';
import '../../theme/palette.dart';

/// Hand-drawn brushed silhouettes for each guardian. These are intentionally
/// minimal — small, calligraphic ink shapes rather than photoreal art —
/// because that's the visual language of 山海经 illustrations.
///
/// All sized inside a unit box (0..1, 0..1); call [paintGuardian] which
/// applies the requested center + size.
void paintGuardian(
  Canvas canvas,
  Guardian g, {
  required Offset center,
  required double size,
  double phase = 0,
  Color ink = Palette.moHei,
  Color accent = Palette.zhuSha,
}) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  switch (g) {
    case Guardian.dragon:
      _paintDragon(canvas, size, phase, ink, accent);
      break;
    case Guardian.phoenix:
      _paintPhoenix(canvas, size, phase, ink, accent);
      break;
    case Guardian.crane:
      _paintCrane(canvas, size, phase, ink);
      break;
    case Guardian.changE:
      _paintChangE(canvas, size, phase, ink, accent);
      break;
    case Guardian.fox:
      _paintFox(canvas, size, phase, ink, accent);
      break;
    case Guardian.qilin:
      _paintQilin(canvas, size, phase, ink, accent);
      break;
    case Guardian.koi:
      _paintKoi(canvas, size, phase, ink, accent);
      break;
    case Guardian.monkey:
      _paintMonkey(canvas, size, phase, ink, accent);
      break;
    case Guardian.snake:
      _paintSnake(canvas, size, phase, ink, accent);
      break;
  }
  canvas.restore();
}

Paint _ink(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..strokeWidth = w;

void _paintDragon(
    Canvas c, double s, double phase, Color ink, Color accent) {
  // Coiled S-curve body with two horns and clawed feet.
  final wob = sin(phase * 1.6) * 0.04 * s;
  final p = Path()
    ..moveTo(-s * 0.6, -s * 0.3 + wob)
    ..cubicTo(-s * 0.4, -s * 0.7, s * 0.1, -s * 0.0, s * 0.4, -s * 0.4 + wob)
    ..cubicTo(s * 0.7, -s * 0.7, s * 0.7, -s * 0.0, s * 0.55, s * 0.25);
  c.drawPath(p, _ink(ink, s * 0.06));
  // Horns
  c.drawLine(Offset(s * 0.55, s * 0.25), Offset(s * 0.7, s * 0.40),
      _ink(ink, s * 0.04));
  c.drawLine(Offset(s * 0.55, s * 0.25), Offset(s * 0.65, s * 0.43),
      _ink(ink, s * 0.04));
  // Eye / cinnabar pearl
  c.drawCircle(Offset(s * 0.55, s * 0.28), s * 0.04, Paint()..color = accent);
  // Whisker
  c.drawLine(Offset(s * 0.5, s * 0.32),
      Offset(s * 0.7 + sin(phase * 2) * 4, s * 0.5), _ink(ink, s * 0.02));
  // Cloud puff under
  c.drawArc(
    Rect.fromCenter(center: Offset(0, s * 0.55), width: s * 1.4, height: s * 0.22),
    pi,
    pi,
    false,
    _ink(ink.withOpacity(0.35), s * 0.04),
  );
}

void _paintPhoenix(
    Canvas c, double s, double phase, Color ink, Color accent) {
  // Upswept body + sweeping tail feathers.
  final body = Path()
    ..moveTo(-s * 0.1, 0)
    ..quadraticBezierTo(s * 0.0, -s * 0.4, s * 0.25, -s * 0.45)
    ..quadraticBezierTo(s * 0.4, -s * 0.4, s * 0.4, -s * 0.2);
  c.drawPath(body, _ink(ink, s * 0.06));
  // Beak + crest
  c.drawLine(Offset(s * 0.4, -s * 0.45), Offset(s * 0.55, -s * 0.5),
      _ink(accent, s * 0.04));
  // Tail feathers — three sweeping curves with cinnabar tips.
  for (int i = 0; i < 3; i++) {
    final lift = (i - 1) * s * 0.18;
    final p = Path()
      ..moveTo(-s * 0.1, 0)
      ..cubicTo(-s * 0.4, -s * 0.0 + lift, -s * 0.7, -s * 0.15 + lift,
          -s * 0.95, -s * 0.05 + lift + sin(phase + i) * s * 0.04);
    c.drawPath(p, _ink(ink, s * 0.04));
    c.drawCircle(
        Offset(-s * 0.95, -s * 0.05 + lift + sin(phase + i) * s * 0.04),
        s * 0.03,
        Paint()..color = accent);
  }
}

void _paintCrane(Canvas c, double s, double phase, Color ink) {
  // Long S-neck + body + tail + leg.
  final neck = Path()
    ..moveTo(s * 0.3, -s * 0.5 + sin(phase * 0.6) * s * 0.02)
    ..quadraticBezierTo(s * 0.0, -s * 0.4, -s * 0.05, -s * 0.05);
  c.drawPath(neck, _ink(ink, s * 0.05));
  // Body
  c.drawOval(
      Rect.fromCenter(
          center: Offset(-s * 0.15, s * 0.05),
          width: s * 0.55,
          height: s * 0.30),
      Paint()..color = ink);
  // Tail
  c.drawLine(Offset(-s * 0.4, s * 0.05), Offset(-s * 0.6, -s * 0.05),
      _ink(ink, s * 0.05));
  // Beak
  c.drawLine(Offset(s * 0.3, -s * 0.5), Offset(s * 0.45, -s * 0.45),
      _ink(ink, s * 0.025));
  // Leg
  c.drawLine(Offset(-s * 0.1, s * 0.18), Offset(-s * 0.05, s * 0.55),
      _ink(ink, s * 0.025));
  // Red crown dot
  c.drawCircle(Offset(s * 0.3, -s * 0.55), s * 0.04,
      Paint()..color = const Color(0xFFB83D2E));
}

void _paintChangE(
    Canvas c, double s, double phase, Color ink, Color accent) {
  // Moon disc with rabbit silhouette. Phase animates a soft pulse.
  final pulse = 1.0 + sin(phase) * 0.04;
  c.drawCircle(Offset.zero, s * 0.4 * pulse,
      Paint()..color = Palette.yueBai.withOpacity(0.95));
  c.drawCircle(
    Offset.zero,
    s * 0.5 * pulse,
    Paint()
      ..color = Palette.yueBai.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
  );
  // Jade rabbit: two ears + crouched body.
  final body = Paint()..color = ink.withOpacity(0.85);
  c.drawOval(
      Rect.fromCenter(center: Offset(0, s * 0.05), width: s * 0.28, height: s * 0.18),
      body);
  c.drawOval(
      Rect.fromCenter(
          center: Offset(-s * 0.05, -s * 0.12),
          width: s * 0.05,
          height: s * 0.16),
      body);
  c.drawOval(
      Rect.fromCenter(
          center: Offset(s * 0.05, -s * 0.12),
          width: s * 0.05,
          height: s * 0.16),
      body);
}

void _paintFox(Canvas c, double s, double phase, Color ink, Color accent) {
  // Curved body + nine tail flicks.
  final body = Path()
    ..moveTo(-s * 0.05, 0)
    ..quadraticBezierTo(s * 0.2, -s * 0.05, s * 0.35, -s * 0.18)
    ..lineTo(s * 0.45, -s * 0.32)
    ..lineTo(s * 0.5, -s * 0.18)
    ..quadraticBezierTo(s * 0.4, 0, s * 0.0, s * 0.05)
    ..close();
  c.drawPath(body, Paint()..color = accent.withOpacity(0.9));
  // Nine tails
  for (int i = 0; i < 9; i++) {
    final spread = (i / 8 - 0.5) * 1.6;
    final p = Path()
      ..moveTo(-s * 0.05, s * 0.0)
      ..quadraticBezierTo(
          -s * 0.3,
          spread * s * 0.18 + sin(phase + i) * s * 0.02,
          -s * 0.6,
          spread * s * 0.32);
    c.drawPath(p, _ink(accent.withOpacity(0.7), s * 0.03));
    c.drawCircle(Offset(-s * 0.6, spread * s * 0.32), s * 0.02,
        Paint()..color = Palette.yueBai);
  }
  // Eye
  c.drawCircle(Offset(s * 0.4, -s * 0.22), s * 0.02, Paint()..color = ink);
}

void _paintQilin(Canvas c, double s, double phase, Color ink, Color accent) {
  // Hooved body + scales pattern + single horn.
  final body = Path()
    ..moveTo(-s * 0.4, s * 0.1)
    ..quadraticBezierTo(-s * 0.4, -s * 0.25, -s * 0.1, -s * 0.30)
    ..quadraticBezierTo(s * 0.2, -s * 0.32, s * 0.4, -s * 0.18)
    ..quadraticBezierTo(s * 0.45, s * 0.05, s * 0.4, s * 0.18)
    ..lineTo(-s * 0.4, s * 0.18)
    ..close();
  c.drawPath(body, Paint()..color = accent.withOpacity(0.85));
  // Scales (cinnabar dots)
  for (int i = 0; i < 12; i++) {
    final x = -s * 0.3 + (i % 6) * s * 0.13;
    final y = i < 6 ? -s * 0.18 : -s * 0.05;
    c.drawCircle(Offset(x, y), s * 0.018, Paint()..color = ink.withOpacity(0.5));
  }
  // Horn
  c.drawLine(Offset(s * 0.35, -s * 0.3), Offset(s * 0.5, -s * 0.5),
      _ink(ink, s * 0.04));
  // Legs
  for (int i = 0; i < 4; i++) {
    final x = -s * 0.32 + i * s * 0.22;
    c.drawLine(Offset(x, s * 0.18), Offset(x, s * 0.42), _ink(ink, s * 0.03));
  }
}

void _paintKoi(Canvas c, double s, double phase, Color ink, Color accent) {
  // Up-leaping koi (cinnabar splotches + black eye).
  final wag = sin(phase * 4) * 0.4;
  final body = Paint()..color = Palette.yueBai;
  c.drawOval(
      Rect.fromCenter(center: Offset.zero, width: s * 0.85, height: s * 0.32),
      body);
  c.drawCircle(Offset(-s * 0.1, -s * 0.02), s * 0.10, Paint()..color = accent);
  c.drawCircle(Offset(s * 0.18, s * 0.04), s * 0.06, Paint()..color = accent);
  // Tail
  final tail = Path()
    ..moveTo(-s * 0.42, 0)
    ..quadraticBezierTo(-s * 0.6, s * 0.18 * wag, -s * 0.7, s * 0.30 * wag)
    ..lineTo(-s * 0.7, -s * 0.30 * wag)
    ..quadraticBezierTo(-s * 0.6, -s * 0.18 * wag, -s * 0.42, 0)
    ..close();
  c.drawPath(tail, body);
  // Eye
  c.drawCircle(Offset(s * 0.32, -s * 0.04), s * 0.025, Paint()..color = ink);
}

void _paintMonkey(
    Canvas c, double s, double phase, Color ink, Color accent) {
  // Tiny silhouette of Sun Wukong on a cloud, holding a staff.
  // Cloud
  final cloud = Paint()..color = Palette.yueBai.withOpacity(0.95);
  c.drawArc(
      Rect.fromCenter(
          center: Offset(0, s * 0.3),
          width: s * 0.9,
          height: s * 0.3),
      pi,
      pi,
      false,
      Paint()
        ..color = Palette.yueBai
        ..style = PaintingStyle.fill);
  c.drawCircle(Offset(-s * 0.25, s * 0.28), s * 0.12, cloud);
  c.drawCircle(Offset(s * 0.25, s * 0.28), s * 0.12, cloud);
  // Body
  c.drawOval(
      Rect.fromCenter(
          center: Offset(0, -s * 0.05), width: s * 0.18, height: s * 0.30),
      Paint()..color = ink);
  // Head
  c.drawCircle(Offset(0, -s * 0.30), s * 0.12, Paint()..color = ink);
  // Headband (cinnabar)
  c.drawLine(Offset(-s * 0.13, -s * 0.30), Offset(s * 0.13, -s * 0.30),
      _ink(accent, s * 0.04));
  // Staff
  c.drawLine(
      Offset(s * 0.12 + sin(phase * 3) * 2, -s * 0.45),
      Offset(s * 0.32 + sin(phase * 3) * 4, s * 0.18),
      _ink(accent, s * 0.04));
}

void _paintSnake(
    Canvas c, double s, double phase, Color ink, Color accent) {
  // White serpent — long S-curve, head with a small cinnabar tongue.
  final p = Path()
    ..moveTo(-s * 0.6, s * 0.0 + sin(phase) * s * 0.02)
    ..cubicTo(-s * 0.3, -s * 0.4, s * 0.1, s * 0.4, s * 0.5, -s * 0.05);
  c.drawPath(p, _ink(Palette.yueBai, s * 0.10));
  c.drawPath(p, _ink(Palette.danMo.withOpacity(0.4), s * 0.04));
  // Head
  c.drawCircle(Offset(s * 0.5, -s * 0.05), s * 0.06, Paint()..color = Palette.yueBai);
  // Tongue
  c.drawLine(Offset(s * 0.55, -s * 0.05), Offset(s * 0.7, -s * 0.05),
      _ink(accent, s * 0.02));
}
