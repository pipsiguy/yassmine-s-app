import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/guardian.dart';
import '../../models/note.dart';
import '../../rendering/paper/rice_paper.dart';
import '../../storage/note_repo.dart';
import '../../theme/motion.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'brush_editor.dart';
import 'seal.dart';

/// Full-screen handscroll editor — open from a pin or the brush button.
/// Two wooden rollers slide outward, exposing rice paper between them.
class NotePage extends StatefulWidget {
  final NoteRepo repo;
  final Note? initial;

  const NotePage({super.key, required this.repo, this.initial});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _title =
      TextEditingController(text: widget.initial?.title ?? '');
  late final TextEditingController _body =
      TextEditingController(text: widget.initial?.body ?? '');
  late Mood _mood = widget.initial?.mood ?? Mood.calm;
  late WuxingElement _element = widget.initial?.element ?? WuxingElement.water;

  late final AnimationController _unfurl = AnimationController(
    vsync: this,
    duration: Motion.slow,
  )..forward();

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _unfurl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final n = widget.initial;
    if (n == null) {
      await widget.repo.create(
        title: _title.text.trim(),
        body: _body.text.trim(),
        mood: _mood,
        element: _element,
      );
    } else {
      await widget.repo.update(n.copyWith(
        title: _title.text.trim(),
        body: _body.text.trim(),
        mood: _mood,
        element: _element,
      ));
    }
    if (!mounted) return;
    await _unfurl.reverse();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.muSe.withOpacity(0.4),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _unfurl,
          builder: (_, __) {
            final t = Motion.unfurl.transform(_unfurl.value);
            return Stack(
              fit: StackFit.expand,
              children: [
                // Backdrop tap to dismiss.
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () async {
                      await _unfurl.reverse();
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
                // The handscroll itself.
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 28),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: RicePaper(
                        paper: Palette.xuanZhi,
                        intensity: 0.8,
                        child: Stack(
                          children: [
                            // Paper content.
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(12, 18, 12, 12),
                              child: Opacity(
                                opacity: t,
                                child: BrushEditor(
                                  title: _title,
                                  body: _body,
                                  mood: _mood,
                                  element: _element,
                                  onMoodChanged: (m) =>
                                      setState(() => _mood = m),
                                  onElementChanged: (e) =>
                                      setState(() => _element = e),
                                ),
                              ),
                            ),
                            // Existing seal indicator if editing.
                            if (widget.initial != null)
                              Positioned(
                                left: 16,
                                bottom: 16,
                                child: Opacity(
                                  opacity: 0.7,
                                  child: Text(
                                    widget.initial!.guardian.glyph,
                                    style: AppType.brush(
                                        size: 28,
                                        color: Palette.zhuSha,
                                        letter: 0),
                                  ),
                                ),
                              ),
                            // Two wooden rollers slide outward.
                            _Roller(side: -1, t: t),
                            _Roller(side: 1, t: t),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: Motion.med),
                ),
                // Bottom seal.
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: CinnabarSeal(
                      glyph: _mood.glyph,
                      onSealed: _save,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// One of the two wooden rollers on either edge of the handscroll.
/// `side`: -1 = left, +1 = right. `t` 0..1 drives the unfurl.
class _Roller extends StatelessWidget {
  final int side;
  final double t;
  const _Roller({required this.side, required this.t});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: side == -1 ? 0 : null,
      right: side == 1 ? 0 : null,
      width: 22,
      child: FractionalTranslation(
        translation: Offset(side * (1 - t) * 0.5, 0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Palette.oCher.withOpacity(0.85),
                Palette.huangJin,
                Palette.oCher.withOpacity(0.85),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 8,
                offset: Offset(side * 1.0, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
