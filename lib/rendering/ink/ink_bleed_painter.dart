import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/palette.dart';

/// Animated ink-drop spreading across the canvas. Used in onboarding and
/// briefly when a new note's pin is placed on the realm map.
class InkBleed extends StatefulWidget {
  final Duration duration;
  final Offset center;
  final Color ink;
  final Color paper;
  final VoidCallback? onComplete;

  const InkBleed({
    super.key,
    this.duration = const Duration(milliseconds: 1600),
    required this.center,
    this.ink = Palette.moHei,
    this.paper = Palette.xuanZhi,
    this.onComplete,
  });

  @override
  State<InkBleed> createState() => _InkBleedState();
}

class _InkBleedState extends State<InkBleed>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl =
      AnimationController(vsync: this, duration: widget.duration)
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed) widget.onComplete?.call();
        })
        ..forward();
  ui.FragmentShader? _shader;
  final _start = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ui.FragmentProgram.fromAsset('shaders/ink_bleed.frag');
    if (!mounted) return;
    setState(() => _shader = p.fragmentShader());
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _shader;
    if (s == null) return Container(color: widget.paper);
    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, __) => CustomPaint(
        painter: _Painter(
          shader: s,
          progress: _ctl.value,
          time: DateTime.now().difference(_start).inMilliseconds / 1000.0,
          center: widget.center,
          ink: widget.ink,
          paper: widget.paper,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final ui.FragmentShader shader;
  final double progress;
  final double time;
  final Offset center;
  final Color ink;
  final Color paper;

  _Painter({
    required this.shader,
    required this.progress,
    required this.time,
    required this.center,
    required this.ink,
    required this.paper,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, center.dx)
      ..setFloat(4, center.dy)
      ..setFloat(5, progress)
      ..setFloat(6, ink.red / 255.0)
      ..setFloat(7, ink.green / 255.0)
      ..setFloat(8, ink.blue / 255.0)
      ..setFloat(9, ink.alpha / 255.0)
      ..setFloat(10, paper.red / 255.0)
      ..setFloat(11, paper.green / 255.0)
      ..setFloat(12, paper.blue / 255.0)
      ..setFloat(13, paper.alpha / 255.0);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _Painter old) =>
      old.progress != progress || old.time != time;
}
