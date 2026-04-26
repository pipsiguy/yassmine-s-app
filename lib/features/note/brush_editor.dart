import 'package:flutter/material.dart';

import '../../models/guardian.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';

/// Rice-paper text fields. Title in 马善政 brush, body in Noto Serif SC.
class BrushEditor extends StatelessWidget {
  final TextEditingController title;
  final TextEditingController body;
  final Mood mood;
  final WuxingElement element;
  final ValueChanged<Mood> onMoodChanged;
  final ValueChanged<WuxingElement> onElementChanged;

  const BrushEditor({
    super.key,
    required this.title,
    required this.body,
    required this.mood,
    required this.element,
    required this.onMoodChanged,
    required this.onElementChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: title,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: AppType.brush(size: 36, color: Palette.moHei, letter: 6),
          decoration: InputDecoration(
            hintText: 'Title',
            hintStyle: AppType.brush(
                size: 32,
                color: Palette.danMo.withOpacity(0.35),
                letter: 6),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 1,
          color: Palette.danMo.withOpacity(0.18),
          margin: const EdgeInsets.symmetric(horizontal: 24),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: TextField(
            controller: body,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: AppType.serif(size: 18, color: Palette.moHei),
            decoration: InputDecoration(
              hintText: 'Write here.',
              hintStyle: AppType.serif(
                  size: 18, color: Palette.danMo.withOpacity(0.4)),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Mood + element pickers.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final m in Mood.values)
                        _Chip(
                          glyph: m.glyph,
                          label: m.label,
                          selected: m == mood,
                          color: Palette.zhuSha,
                          onTap: () => onMoodChanged(m),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final e in WuxingElement.values)
                  _Chip(
                    glyph: e.glyph,
                    label: e.label,
                    selected: e == element,
                    color: Palette.daiQing,
                    onTap: () => onElementChanged(e),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String glyph;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _Chip({
    required this.glyph,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected ? color : Colors.transparent,
          border: Border.all(
            color: selected ? color : color.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              glyph,
              style: AppType.brush(
                size: 22,
                color: selected ? Palette.yueBai : color,
                letter: 1,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: AppType.sans(
                size: 9,
                color: selected
                    ? Palette.yueBai.withOpacity(0.9)
                    : color.withOpacity(0.75),
                letter: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
