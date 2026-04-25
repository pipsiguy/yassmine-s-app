import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../theme/palette.dart';

/// Falling plum / peach petals (梅花 / 桃花). Each petal is a tiny tilted
/// oval that sways as it drifts down the screen.
class PetalRain extends StatefulWidget {
  final int count;
  final List<Color> palette;
  final double wind;

  const PetalRain({
    super.key,
    this.count = 40,
    this.palette = const [Palette.taoHong, Palette.meiZi, Palette.yueBai],
    this.wind = 14,
  });

  @override
  State<PetalRain> createState() => _PetalRainState();
}

class _Petal {
  Offset pos;
  double r;
  double rot;
  double rotV;
  double size;
  Color color;
  double swayPhase;
  double swayAmp;
  _Petal({
    required this.pos,
    required this.r,
    required this.rot,
    required this.rotV,
    required this.size,
    required this.color,
    required this.swayPhase,
    required this.swayAmp,
  });
}

class _PetalRainState extends State<PetalRain>
    with SingleTickerProviderStateMixin {
  final _rng = Random(7);
  late List<_Petal> _petals;
  Size _size = Size.zero;
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _t = 0;

  @override
  void initState() {
    super.initState();
    _petals = [];
    _ticker = createTicker(_tick)..start();
  }

  void _seed(Size s) {
    if (_petals.length == widget.count && _size == s) return;
    _size = s;
    _petals = List.generate(widget.count, (_) {
      return _Petal(
        pos: Offset(_rng.nextDouble() * s.width,
            _rng.nextDouble() * s.height - s.height),
        r: 0.6 + _rng.nextDouble() * 1.6,
        rot: _rng.nextDouble() * pi * 2,
        rotV: (_rng.nextDouble() - 0.5) * 1.4,
        size: 4 + _rng.nextDouble() * 6,
        color: widget.palette[_rng.nextInt(widget.palette.length)],
        swayPhase: _rng.nextDouble() * pi * 2,
        swayAmp: 8 + _rng.nextDouble() * 22,
      );
    });
  }

  void _tick(Duration t) {
    final dt = (t - _last).inMicroseconds / 1e6;
    _last = t;
    _t += dt;
    if (_size == Size.zero) return;
    for (final p in _petals) {
      p.rot += p.rotV * dt;
      final sway = sin(_t * 1.3 + p.swayPhase) * p.swayAmp;
      p.pos = Offset(
        p.pos.dx + (widget.wind + sway) * dt * 0.6,
        p.pos.dy + (16 + p.r * 22) * dt,
      );
      if (p.pos.dy > _size.height + 30) {
        p.pos = Offset(_rng.nextDouble() * _size.width, -20);
      }
      if (p.pos.dx > _size.width + 30) {
        p.pos = Offset(-30, p.pos.dy);
      }
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
        painter: _PetalsPainter(_petals),
        size: Size.infinite,
      );
    });
  }
}

class _PetalsPainter extends CustomPainter {
  final List<_Petal> petals;
  _PetalsPainter(this.petals);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in petals) {
      canvas.save();
      canvas.translate(p.pos.dx, p.pos.dy);
      canvas.rotate(p.rot);
      final paint = Paint()..color = p.color.withOpacity(0.85);
      // Petal shape — squashed teardrop.
      final path = Path()
        ..moveTo(0, -p.size)
        ..quadraticBezierTo(p.size * 0.6, -p.size * 0.4, p.size * 0.5, p.size * 0.3)
        ..quadraticBezierTo(0, p.size * 0.7, -p.size * 0.5, p.size * 0.3)
        ..quadraticBezierTo(-p.size * 0.6, -p.size * 0.4, 0, -p.size);
      canvas.drawPath(path, paint);
      // Soft inner highlight.
      canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withOpacity(0.18)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PetalsPainter old) => true;
}
