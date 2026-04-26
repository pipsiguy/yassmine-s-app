import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../rendering/ink/ink_bleed_painter.dart';
import '../../rendering/paper/rice_paper.dart';
import '../../storage/note_repo.dart';
import '../../theme/motion.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';

/// First-run experience: ink drop falls onto blank rice paper, ripples
/// spread, calligraphy asks the user to name their realm.
class DropPage extends StatefulWidget {
  final NoteRepo repo;
  final VoidCallback onComplete;
  const DropPage({super.key, required this.repo, required this.onComplete});

  @override
  State<DropPage> createState() => _DropPageState();
}

class _DropPageState extends State<DropPage> {
  bool _bled = false;
  final _name = TextEditingController(text: 'Lanruo');

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    await widget.repo.setRealmName(_name.text.trim());
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RicePaper(
        paper: Palette.xuanZhi,
        intensity: 1.0,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ink-drop animation runs once.
            if (!_bled)
              IgnorePointer(
                child: InkBleed(
                  center: Offset(
                    MediaQuery.of(context).size.width / 2,
                    MediaQuery.of(context).size.height / 2,
                  ),
                  paper: Palette.xuanZhi,
                  ink: Palette.moHei,
                  duration: Motion.ceremony,
                  onComplete: () => setState(() => _bled = true),
                ),
              ),
            // After the drop has bled, fade in the prompt.
            AnimatedOpacity(
              opacity: _bled ? 1 : 0,
              duration: Motion.med,
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Shanhai',
                          style: AppType.brush(
                              size: 76, color: Palette.moHei, letter: 6),
                        ).animate().fadeIn(duration: Motion.slow),
                        const SizedBox(height: 6),
                        Text(
                          'a notes app · mountains and seas',
                          style: AppType.latin(
                              size: 13, color: Palette.danMo),
                        ),
                        const SizedBox(height: 56),
                        Text(
                          'What shall this realm be called?',
                          style: AppType.sans(
                              size: 14,
                              color: Palette.danMo.withOpacity(0.85)),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 260,
                          child: TextField(
                            controller: _name,
                            textAlign: TextAlign.center,
                            style: AppType.brush(
                                size: 36,
                                color: Palette.moHei,
                                letter: 8),
                            decoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Palette.zhuSha.withOpacity(0.7)),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Palette.danMo.withOpacity(0.4)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        TextButton(
                          onPressed: _confirm,
                          style: TextButton.styleFrom(
                            backgroundColor: Palette.zhuSha,
                            foregroundColor: Palette.yueBai,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 14),
                          ),
                          child: Text(
                            'Seal',
                            style: AppType.brush(
                                size: 22, color: Palette.yueBai, letter: 4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
