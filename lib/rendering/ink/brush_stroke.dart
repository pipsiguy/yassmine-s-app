import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/palette.dart';

/// Draws an ink brushstroke along a path with width that tapers like a
/// real wolf-hair brush. Used by the realm painter to draw mountains,
/// rivers, and the calligraphy-line intros.
class BrushStrokePainter {
  static void stroke(
    Canvas canvas,
    Path path, {
    Color color = Palette.moHei,
    double width = 14,
    double tipNarrow = 0.25,
    double opacity = 1.0,
  }) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final m in metrics) {
      const segs = 24;
      final len = m.length;
      for (var i = 0; i < segs; i++) {
        final t0 = i / segs;
        final t1 = (i + 1) / segs;
        // Width tapers in at start, plateaus, tapers out at end.
        final mid = (t0 + t1) / 2;
        final w = _taper(mid, tipNarrow) * width;
        paint.strokeWidth = w;

        final p0 = m.getTangentForOffset(t0 * len)?.position;
        final p1 = m.getTangentForOffset(t1 * len)?.position;
        if (p0 == null || p1 == null) continue;
        canvas.drawLine(p0, p1, paint);
      }
    }
  }

  static double _taper(double t, double tipNarrow) {
    // Symmetric pinch: full at the middle, [tipNarrow] at the ends.
    final pinch = sin(pi * t.clamp(0.0, 1.0));
    return tipNarrow + (1 - tipNarrow) * pinch;
  }

  /// A single mountain silhouette as a brushed path. Returns the path so
  /// callers can also use it for masking/animations.
  static Path mountain({
    required Offset apex,
    required double width,
    required double height,
    double jaggedness = 0.18,
    int seed = 0,
  }) {
    final r = Random(seed);
    final path = Path()
      ..moveTo(apex.dx - width / 2, apex.dy + height);
    final steps = 12;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      // Ridge curve: rise to apex, fall on the other side.
      final x = apex.dx - width / 2 + t * width;
      final base = apex.dy + height - sin(pi * t).abs() * height;
      final jitter = (r.nextDouble() - 0.5) * height * jaggedness;
      path.lineTo(x, base + jitter);
    }
    path.lineTo(apex.dx + width / 2, apex.dy + height);
    path.close();
    return path;
  }
}
