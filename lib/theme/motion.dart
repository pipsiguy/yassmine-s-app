import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

/// Motion presets named after classical aesthetic ideas:
/// 收 (shōu) — gather; 放 (fàng) — release; 含蓄 (hánxù) — restrained.
class Motion {
  const Motion._();

  // Timings ---------------------------------------------------------------
  static const fast = Duration(milliseconds: 220);
  static const med = Duration(milliseconds: 420);
  static const slow = Duration(milliseconds: 720);
  static const ceremony = Duration(milliseconds: 1400);

  // Curves ----------------------------------------------------------------
  /// Brush stroke acceleration — quick on-paper, slow on lift.
  static const brush = Cubic(0.22, 1.0, 0.36, 1.0);

  /// Ink drop — fast, with a slight overshoot.
  static const inkDrop = Cubic(0.34, 1.56, 0.64, 1.0);

  /// Page unfurl — gentle, like a hand pulling a scroll.
  static const unfurl = Cubic(0.6, 0.0, 0.2, 1.0);

  /// Soft restraint — the standard 含蓄 curve.
  static const hanxu = Cubic(0.4, 0.05, 0.2, 1.0);

  // Springs ---------------------------------------------------------------
  /// Stems and pins sway in the wind with this spring.
  static SpringDescription get reedSpring =>
      SpringDescription.withDampingRatio(mass: 1, stiffness: 60, ratio: 0.42);

  /// Seal stamp — heavy press, quick rebound.
  static SpringDescription get sealSpring =>
      SpringDescription.withDampingRatio(mass: 1, stiffness: 380, ratio: 0.55);
}
