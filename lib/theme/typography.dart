import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'palette.dart';

/// Three CJK families used across the app.
///
/// - **Brush** (马善政 / Ma Shan Zheng): titles, hero numerals, the seal.
/// - **Serif** (思源宋体 / Noto Serif SC): note body, calligraphic prose.
/// - **Sans**  (思源黑体 / Noto Sans SC): chrome and metadata.
class AppType {
  const AppType._();

  static TextStyle brush({
    double size = 64,
    Color color = Palette.inkPrimary,
    double letter = 4,
  }) =>
      GoogleFonts.maShanZheng(
        textStyle: TextStyle(
          fontSize: size,
          color: color,
          height: 1.0,
          letterSpacing: letter,
        ),
      );

  static TextStyle serif({
    double size = 18,
    Color color = Palette.inkPrimary,
    FontWeight weight = FontWeight.w400,
    double height = 1.65,
  }) =>
      GoogleFonts.notoSerifSc(
        textStyle: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: weight,
          height: height,
        ),
      );

  static TextStyle sans({
    double size = 14,
    Color color = Palette.inkSoft,
    FontWeight weight = FontWeight.w400,
    double letter = 0.4,
  }) =>
      GoogleFonts.notoSansSc(
        textStyle: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: weight,
          letterSpacing: letter,
        ),
      );

  /// Latin fallback for poetic English text. Source Serif 4 ships with
  /// google_fonts and looks at home next to Noto Serif SC.
  static TextStyle latin({double size = 16, Color color = Palette.inkPrimary}) =>
      GoogleFonts.sourceSerif4(
        textStyle: TextStyle(fontSize: size, color: color, height: 1.55),
      );
}
