import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/palette.dart';

/// Full-bleed rice paper using the `paper_grain.frag` shader.
class RicePaper extends StatefulWidget {
  final Widget child;
  final Color paper;
  final double intensity;

  const RicePaper({
    super.key,
    required this.child,
    this.paper = Palette.xuanZhi,
    this.intensity = 0.9,
  });

  @override
  State<RicePaper> createState() => _RicePaperState();
}

class _RicePaperState extends State<RicePaper> {
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final program =
        await ui.FragmentProgram.fromAsset('shaders/paper_grain.frag');
    if (!mounted) return;
    setState(() => _shader = program.fragmentShader());
  }

  @override
  Widget build(BuildContext context) {
    final shader = _shader;
    if (shader == null) {
      return Container(color: widget.paper, child: widget.child);
    }
    return CustomPaint(
      painter: _PaperPainter(shader, widget.paper, widget.intensity),
      child: widget.child,
    );
  }
}

class _PaperPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final Color paper;
  final double intensity;

  _PaperPainter(this.shader, this.paper, this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, 0.0) // uTime (unused)
      ..setFloat(3, paper.red / 255.0)
      ..setFloat(4, paper.green / 255.0)
      ..setFloat(5, paper.blue / 255.0)
      ..setFloat(6, paper.alpha / 255.0)
      ..setFloat(7, intensity);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _PaperPainter old) =>
      old.paper != paper || old.intensity != intensity;
}
