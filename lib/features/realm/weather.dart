import 'package:flutter/material.dart';

import '../../rendering/particles/cloud_field.dart';
import '../../rendering/particles/fireflies.dart';
import '../../rendering/particles/koi_school.dart';
import '../../rendering/particles/petals.dart';
import '../../theme/palette.dart';
import '../../utils/lunar.dart';

/// Layered atmospheric effects on top of the realm. What's visible depends
/// on time of day:
///   day   — clouds + petals + koi
///   dusk  — clouds (warm) + koi
///   night — clouds (cool, dim) + fireflies
class Weather extends StatelessWidget {
  final DateTime now;
  final double quality; // 0..1, throttle particle counts on weak devices
  const Weather({super.key, required this.now, this.quality = 1});

  @override
  Widget build(BuildContext context) {
    final band = SkyBand.now(now).band;
    final cloudColor = switch (band) {
      0 => Palette.yueBai.withOpacity(0.55),  // dawn
      1 => Palette.yueBai.withOpacity(0.78),  // day
      2 => Palette.taoHong.withOpacity(0.55), // dusk
      _ => Palette.daiQing.withOpacity(0.45), // night
    };
    final cloudDensity = switch (band) { 1 => 0.6, 2 => 0.55, _ => 0.45 };
    final petalCount = (band == 1 ? 36 : band == 0 ? 22 : 0) * quality.toInt();
    final fireflyCount = (band == 3 ? 28 : band == 2 ? 8 : 0) * quality.toInt();
    final koiCount = (band == 3 ? 0 : 5);

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: CloudField(
            density: cloudDensity.toDouble(),
            wind: 14,
            color: cloudColor,
          ),
        ),
        if (petalCount > 0)
          IgnorePointer(child: PetalRain(count: petalCount)),
        if (fireflyCount > 0)
          IgnorePointer(child: Fireflies(count: fireflyCount)),
        if (koiCount > 0) IgnorePointer(child: KoiSchool(count: koiCount)),
      ],
    );
  }
}
