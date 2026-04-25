import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../models/note.dart';
import '../../theme/motion.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'creatures.dart';

/// A pin on the realm map: a tiny mountain-or-shrine with the note's
/// guardian creature painted above and the note's title beneath. Sways in
/// the wind and pulses gently when focused.
class RealmPin extends StatefulWidget {
  final Note note;
  final bool focused;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const RealmPin({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
    this.focused = false,
  });

  @override
  State<RealmPin> createState() => _RealmPinState();
}

class _RealmPinState extends State<RealmPin>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _t = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((d) {
      setState(() => _t = d.inMicroseconds / 1e6);
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phase = (widget.note.id.hashCode % 1000) / 1000.0;
    final sway = sin(_t * 1.4 + phase * pi * 2) * 4;
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Transform.translate(
        offset: Offset(sway, 0),
        child: SizedBox(
          width: 130,
          height: 150,
          child: CustomPaint(
            painter: _PinPainter(
              note: widget.note,
              t: _t + phase * 6.28,
              focused: widget.focused,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: AnimatedDefaultTextStyle(
                  duration: Motion.fast,
                  style: AppType.brush(
                    size: widget.focused ? 22 : 18,
                    color: Palette.moHei,
                    letter: 2,
                  ),
                  child: Text(
                    widget.note.title.isEmpty
                        ? widget.note.guardian.glyph
                        : widget.note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  final Note note;
  final double t;
  final bool focused;
  _PinPainter({required this.note, required this.t, required this.focused});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final mountainTop = size.height * 0.55;
    final mountainBottom = size.height * 0.92;

    // Mountain silhouette under the creature.
    final colors = Palette.mountainsForElement(note.element);
    final m = Path()
      ..moveTo(cx - 38, mountainBottom)
      ..quadraticBezierTo(cx - 18, mountainTop + 4, cx, mountainTop)
      ..quadraticBezierTo(cx + 18, mountainTop + 4, cx + 38, mountainBottom)
      ..close();
    canvas.drawPath(
      m,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.last, colors[1]],
        ).createShader(Rect.fromLTWH(cx - 40, mountainTop, 80, mountainBottom - mountainTop)),
    );
    // Ridge stroke
    canvas.drawPath(
      m,
      Paint()
        ..color = Palette.moHei.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Glow when focused.
    if (focused) {
      canvas.drawCircle(
        Offset(cx, mountainTop - 8),
        46,
        Paint()
          ..color = Palette.huangJin.withOpacity(0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }

    // Guardian above the peak.
    paintGuardian(
      canvas,
      note.guardian,
      center: Offset(cx, mountainTop - 10),
      size: focused ? 64 : 56,
      phase: t,
      ink: Palette.moHei,
      accent: Palette.zhuSha,
    );

    // Element glyph badge (cinnabar circle on the peak).
    final badge = Offset(cx + 26, mountainTop + 6);
    canvas.drawCircle(badge, 9, Paint()..color = Palette.zhuSha);
    final tp = TextPainter(
      text: TextSpan(
        text: note.element.glyph,
        style: AppType.brush(size: 12, color: Palette.yueBai, letter: 0),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, badge.translate(-tp.width / 2, -tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _PinPainter old) =>
      old.t != t || old.focused != focused;
}
