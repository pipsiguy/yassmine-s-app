import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Drifting 祥云 cloud field, full-bleed. Wired to the cloud.frag shader.
class CloudField extends StatefulWidget {
  final double density;
  final double wind; // px/sec
  final Color color;

  const CloudField({
    super.key,
    this.density = 0.5,
    this.wind = 18,
    this.color = const Color(0xCCFFFFFF),
  });

  @override
  State<CloudField> createState() => _CloudFieldState();
}

class _CloudFieldState extends State<CloudField>
    with SingleTickerProviderStateMixin {
  ui.FragmentShader? _shader;
  late final Ticker _ticker;
  double _t = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((d) {
      setState(() => _t = d.inMicroseconds / 1e6);
    })
      ..start();
    _load();
  }

  Future<void> _load() async {
    final p = await ui.FragmentProgram.fromAsset('shaders/cloud.frag');
    if (!mounted) return;
    setState(() => _shader = p.fragmentShader());
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _shader;
    if (s == null) return const SizedBox.expand();
    return CustomPaint(
      painter: _CloudPainter(
        shader: s,
        time: _t,
        density: widget.density,
        wind: widget.wind,
        color: widget.color,
      ),
      size: Size.infinite,
    );
  }
}

class _CloudPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final double density;
  final double wind;
  final Color color;

  _CloudPainter({
    required this.shader,
    required this.time,
    required this.density,
    required this.wind,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, density)
      ..setFloat(4, wind)
      ..setFloat(5, color.red / 255.0)
      ..setFloat(6, color.green / 255.0)
      ..setFloat(7, color.blue / 255.0)
      ..setFloat(8, color.alpha / 255.0);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _CloudPainter old) => true;
}
