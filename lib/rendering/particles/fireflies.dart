import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../theme/palette.dart';

/// Glowing fireflies — only meaningful at night. Each firefly is a tiny
/// gold dot with a soft halo and a flicker cycle.
class Fireflies extends StatefulWidget {
  final int count;
  final Color color;
  const Fireflies(
      {super.key, this.count = 26, this.color = Palette.huangJin});

  @override
  State<Fireflies> createState() => _FirefliesState();
}

class _Bug {
  Offset p;
  double phase;
  double v;
  double size;
  _Bug(this.p, this.phase, this.v, this.size);
}

class _FirefliesState extends State<Fireflies>
    with SingleTickerProviderStateMixin {
  final _rng = Random(91);
  late List<_Bug> _bugs;
  Size _size = Size.zero;
  late final Ticker _ticker;
  double _t = 0;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _bugs = [];
    _ticker = createTicker(_tick)..start();
  }

  void _seed(Size s) {
    if (_bugs.length == widget.count && _size == s) return;
    _size = s;
    _bugs = List.generate(widget.count, (_) {
      return _Bug(
        Offset(_rng.nextDouble() * s.width, _rng.nextDouble() * s.height),
        _rng.nextDouble() * pi * 2,
        0.4 + _rng.nextDouble() * 0.7,
        2 + _rng.nextDouble() * 2.5,
      );
    });
  }

  void _tick(Duration t) {
    final dt = (t - _last).inMicroseconds / 1e6;
    _last = t;
    _t += dt;
    if (_size == Size.zero) return;
    for (final b in _bugs) {
      // Gentle wandering.
      final angle = sin(_t * b.v + b.phase) * pi;
      b.p += Offset(cos(angle) * 18 * dt, sin(angle * 0.7) * 14 * dt);
      if (b.p.dx < -10) b.p = Offset(_size.width + 10, b.p.dy);
      if (b.p.dx > _size.width + 10) b.p = Offset(-10, b.p.dy);
      if (b.p.dy < -10) b.p = Offset(b.p.dx, _size.height + 10);
      if (b.p.dy > _size.height + 10) b.p = Offset(b.p.dx, -10);
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
        painter: _Painter(_bugs, _t, widget.color),
        size: Size.infinite,
      );
    });
  }
}

class _Painter extends CustomPainter {
  final List<_Bug> bugs;
  final double t;
  final Color color;
  _Painter(this.bugs, this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bugs) {
      final flicker = (sin(t * 3 + b.phase) * 0.5 + 0.5);
      final alpha = (0.35 + 0.55 * flicker).clamp(0.0, 1.0);
      // Halo
      canvas.drawCircle(
        b.p,
        b.size * 5,
        Paint()
          ..color = color.withOpacity(0.10 * alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      // Core
      canvas.drawCircle(
        b.p,
        b.size,
        Paint()..color = color.withOpacity(alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _Painter old) => true;
}
