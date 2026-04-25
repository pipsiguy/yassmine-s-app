import 'dart:math';

import '../models/guardian.dart';
import '../theme/palette.dart';

/// Deterministic per-text seed used to derive map position, palette jitter,
/// and creature variant. Two notes with identical text + timestamp produce
/// identical worlds — but different bodies produce different kingdoms.
class TextSeed {
  final int seed;
  TextSeed(this.seed);

  factory TextSeed.fromText(String text) {
    // Cheap, deterministic 32-bit FNV-1a so we don't drag in crypto.
    var h = 0x811C9DC5;
    for (final c in text.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return TextSeed(h);
  }

  Random get rng => Random(seed);

  /// (mapX, mapY) in 0..1, biased away from the screen edges.
  (double, double) mapPosition() {
    final r = rng;
    final x = 0.10 + r.nextDouble() * 0.80;
    final y = 0.20 + r.nextDouble() * 0.65;
    return (x, y);
  }

  /// Pick the most "fitting" mood from a body of text. This is intentionally
  /// silly — keyword frequency. The user can always override.
  Mood guessMood(String text) {
    final t = text.toLowerCase();
    int score(List<String> words) =>
        words.fold(0, (n, w) => n + (t.contains(w) ? 1 : 0));

    final scores = <Mood, int>{
      Mood.joyful:
          score(['happy', 'joy', 'love', '喜', '爱', 'celebrate', '!']),
      Mood.calm: score(['quiet', 'still', 'breathe', '静', '安', 'slow']),
      Mood.reflective:
          score(['remember', 'mother', 'past', '思', 'miss', 'home']),
      Mood.powerful: score(['must', 'will', 'force', '威', 'strong', 'win']),
      Mood.curious: score(['why', 'wonder', 'maybe', '?', '奇', 'strange']),
      Mood.lucky: score(['hope', 'wish', '福', 'lucky', 'fortune']),
      Mood.adventurous:
          score(['go', 'travel', 'fight', '勇', 'adventure', 'wild']),
      Mood.mysterious:
          score(['dream', 'shadow', 'night', '幽', 'secret', 'fog']),
    };

    var best = Mood.calm;
    var bestScore = -1;
    for (final entry in scores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        best = entry.key;
      }
    }
    if (bestScore == 0) {
      // Fall back to a deterministic pick from the seed.
      return Mood.values[rng.nextInt(Mood.values.length)];
    }
    return best;
  }

  WuxingElement guessElement(String text) {
    final t = text.toLowerCase();
    int score(List<String> ws) =>
        ws.fold(0, (n, w) => n + (t.contains(w) ? 1 : 0));
    final scores = <WuxingElement, int>{
      WuxingElement.wood: score(['tree', 'forest', 'green', '木', 'grow']),
      WuxingElement.fire: score(['fire', 'sun', 'red', '火', 'burn', 'angry']),
      WuxingElement.earth: score(['earth', 'ground', 'home', '土', 'mountain']),
      WuxingElement.metal:
          score(['metal', 'silver', 'sharp', '金', 'cold', 'blade']),
      WuxingElement.water:
          score(['water', 'sea', 'river', '水', 'rain', 'flow', 'tear']),
    };
    var best = WuxingElement.water;
    var bestScore = -1;
    for (final e in scores.entries) {
      if (e.value > bestScore) {
        bestScore = e.value;
        best = e.key;
      }
    }
    if (bestScore == 0) {
      return WuxingElement.values[rng.nextInt(WuxingElement.values.length)];
    }
    return best;
  }
}
