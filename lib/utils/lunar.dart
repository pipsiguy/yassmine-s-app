import 'dart:math' as math;

/// Approximate lunar phase, good enough for a moon icon.
///
/// 0.0 = new moon, 0.5 = full moon, 1.0 = next new moon.
double lunarPhase(DateTime date) {
  // Reference new moon: 2000-01-06 18:14 UTC.
  final ref = DateTime.utc(2000, 1, 6, 18, 14);
  const synodic = 29.530588853; // days per lunar cycle
  final days = date.toUtc().difference(ref).inSeconds / Duration.secondsPerDay;
  final phase = ((days / synodic) % 1 + 1) % 1;
  return phase;
}

/// Sky band: 0=dawn, 1=day, 2=dusk, 3=night. We blend smoothly between
/// adjacent bands using `bandT`.
class SkyBand {
  final int band;
  final double bandT; // 0..1 inside the current band

  const SkyBand(this.band, this.bandT);

  factory SkyBand.now(DateTime t) {
    // Hours-since-midnight as a continuous double.
    final h = t.hour + t.minute / 60.0 + t.second / 3600.0;
    // Bands: night [0..5], dawn [5..8], day [8..17], dusk [17..20], night [20..24].
    if (h < 5) return SkyBand(3, 1.0 - (5 - h) / 9.0);
    if (h < 8) return SkyBand(0, (h - 5) / 3.0);
    if (h < 17) return SkyBand(1, (h - 8) / 9.0);
    if (h < 20) return SkyBand(2, (h - 17) / 3.0);
    return SkyBand(3, math.min(1.0, (h - 20) / 4.0));
  }
}
