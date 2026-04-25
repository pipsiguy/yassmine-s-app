import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../theme/palette.dart';

/// A small school of 锦鲤 (koi) swimming through the foreground sea band.
/// Each koi follows a slow boids-lite drift. Bodies are a stretched ellipse
/// with a wagging tail; cinnabar splotches are seeded per-fish.
class KoiSchool extends StatefulWidget {
  final int count;
  final double yMin; // top of the swim band (0..1)
  final double yMax; // bottom of the swim band (0..1)

  const KoiSchool({
    super.key,
    this.count = 5,
    this.yMin = 0.78,
    this.yMax = 0.98,
  });

  @override
  State<KoiSchool> createState() => _KoiSchoolState();
}

class _Koi {
  Offset p;
  double dir;
  double speed;
  double tailPhase;
  double size;
  double splotchSeed;
  _Koi(this.p, this.dir, this.speed, this.tailPhase, this.size,
      this.splotchSeed);
}

class _KoiSchoolState extends State<KoiSchool>
    with SingleTickerProviderStateMixin {
  final _rng = Random(33);
  late List<_Koi> _fish;
  Size _size = Size.zero;
  late final Ticker _ticker;
  double _t = 0;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fish = [];
    _ticker = createTicker(_tick)..start();
  }

  void _seed(Size s) {
    if (_fish.length == widget.count && _size == s) return;
    _size = s;
    _fish = List.generate(widget.count, (_) {
      final y = (widget.yMin +
              _rng.nextDouble() * (widget.yMax - widget.yMin)) *
          s.height;
      return _Koi(
        Offset(_rng.nextDouble() * s.width, y),
        _rng.nextBool() ? 1.0 : -1.0,
        16 + _rng.nextDouble() * 20,
        _rng.nextDouble() * pi * 2,
        18 + _rng.nextDouble() * 12,
        _rng.nextDouble(),
      );
    });
  }

  void _tick(Duration t) {
    final dt = (t - _last).inMicroseconds / 1e6;
    _last = t;
    _t += dt;
    if (_size == Size.zero) return;
    for (final k in _fish) {
      k.p += Offset(k.dir * k.speed * dt, sin(_t * 0.6 + k.tailPhase) * 4 * dt);
      if (k.p.dx > _size.width + 80) k.p = Offset(-80, k.p.dy);
      if (k.p.dx < -80) k.p = Offset(_size.width + 80, k.p.dy);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      _seed(Size(c.maxWidth, c.maxHeight));
      return CustomPaint(
        painter: _Painter(_fish, _t),
        size: Size.infinite,
      );
    });
  }
}

class _Painter extends CustomPainter {
  final List<_Koi> fish;
  final double t;
  _Painter(this.fish, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final k in fish) {
      canvas.save();
      canvas.translate(k.p.dx, k.p.dy);
      canvas.scale(k.dir, 1);

      // Body
      final body = Paint()..color = Palette.yueBai.withOpacity(0.92);
      canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: k.size * 1.8, height: k.size * 0.7),
          body);
      // Splotches
      final s1 = Paint()..color = Palette.zhuSha.withOpacity(0.85);
      canvas.drawCircle(Offset(-k.size * 0.2, -k.size * 0.05),
          k.size * 0.18 + k.splotchSeed * 4, s1);
      canvas.drawCircle(Offset(k.size * 0.4, k.size * 0.05),
          k.size * 0.12 + (1 - k.splotchSeed) * 3, s1);
      // Tail wag
      final wag = sin(t * 5 + k.tailPhase) * 0.6;
      final tail = Path()
        ..moveTo(-k.size * 0.9, 0)
        ..quadraticBezierTo(-k.size * 1.4, k.size * 0.4 * wag,
            -k.size * 1.6, k.size * 0.7 * wag)
        ..lineTo(-k.size * 1.6, -k.size * 0.7 * wag)
        ..quadraticBezierTo(
            -k.size * 1.4, -k.size * 0.4 * wag, -k.size * 0.9, 0)
        ..close();
      canvas.drawPath(tail, body);
      // Eye
      canvas.drawCircle(Offset(k.size * 0.7, -k.size * 0.05), k.size * 0.05,
          Paint()..color = Palette.moHei);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _Painter old) => true;
}
