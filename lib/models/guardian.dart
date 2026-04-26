/// Mythic creatures the app summons as guardians for individual notes.
///
/// Mood (the writer's feeling) maps to one of these. Each guardian has a
/// short lore line shown when its pin is focused.
enum Guardian {
  dragon('龙', 'lóng',
      'Dragon coiled around the peak — guardian of will and weather.'),
  phoenix('凤凰', 'fènghuáng',
      'Phoenix above the sunset — born of joy and rising warmth.'),
  crane('鹤', 'hè',
      'Crane circling the still pond — long life, quiet morning.'),
  changE('嫦娥', 'cháng\'é',
      'Chang\'e on the moon, with the Jade Rabbit — for nights of memory.'),
  fox('九尾狐', 'jiǔwěihú',
      'Nine-tailed fox in the bamboo grove — keeper of curiosities.'),
  qilin('麒麟', 'qílín',
      'Qilin walks where the air is auspicious — fortune\'s herald.'),
  koi('锦鲤', 'jǐnlǐ',
      'Koi leaping the river — the small luck that turns into a dragon.'),
  monkey('孙悟空', 'sūn wùkōng',
      'The Monkey King on a cloud — restless, daring, undefeated.'),
  snake('白蛇', 'bái shé',
      'The White Snake at dusk — devotion folded in mystery.');

  final String glyph;
  final String pinyin;
  final String lore;
  const Guardian(this.glyph, this.pinyin, this.lore);
}

/// Eight cardinal moods. Mapped 1:1 to the primary guardian roster.
enum Mood {
  joyful('喜', 'joyful', Guardian.phoenix),
  calm('静', 'calm', Guardian.crane),
  reflective('思', 'reflective', Guardian.changE),
  powerful('威', 'powerful', Guardian.dragon),
  curious('奇', 'curious', Guardian.fox),
  lucky('福', 'lucky', Guardian.qilin),
  adventurous('勇', 'bold', Guardian.monkey),
  mysterious('幽', 'mystic', Guardian.snake);

  final String glyph;
  final String label;
  final Guardian guardian;
  const Mood(this.glyph, this.label, this.guardian);
}
