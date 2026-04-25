import 'package:flutter/material.dart';

/// 山海 palette — drawn from classical Chinese pigments.
///
/// Names use their traditional Chinese terms (alongside hex values) so the
/// rest of the app can read in the language of the aesthetic.
class Palette {
  const Palette._();

  // Paper & ink ------------------------------------------------------------
  static const xuanZhi = Color(0xFFF4ECD8);   // 宣纸 — rice paper, day bg
  static const yueBai = Color(0xFFEFEDE3);    // 月白 — moon white
  static const moHei = Color(0xFF1C1A17);     // 墨黑 — ink
  static const danMo = Color(0xFF4A413A);     // 淡墨 — diluted ink
  static const yeKong = Color(0xFF1C2230);    // 夜空 — night sky
  static const muSe = Color(0xFF2F2A36);      // 暮色 — dusk

  // Pigments --------------------------------------------------------------
  static const zhuSha = Color(0xFFB83D2E);    // 朱砂 — cinnabar (seals)
  static const daiQing = Color(0xFF3A5470);   // 黛青 — distant mountain
  static const qingDai = Color(0xFF2F4858);   // 青黛 — closer mountain
  static const huangJin = Color(0xFFC9A861);  // 黄金 — gold leaf
  static const yuLv = Color(0xFF6E8E69);      // 玉绿 — jade
  static const taoHong = Color(0xFFE8A8A0);   // 桃红 — peach blossom
  static const meiZi = Color(0xFFC65A6F);     // 梅子 — plum
  static const tianLan = Color(0xFFA8C4D6);   // 天蓝 — sky
  static const muLan = Color(0xFF564963);     // 暮蓝 — dusk purple
  static const oCher = Color(0xFFB8923D);     // 赭石 — ochre
  static const daiZi = Color(0xFF564963);     // 黛紫 — dusk

  // Semantic --------------------------------------------------------------
  static const inkPrimary = moHei;
  static const inkSoft = danMo;
  static const seal = zhuSha;
  static const accent = zhuSha;

  // Sky bands by hour (used to interpolate the gradient).
  static const skyDawn = [Color(0xFFEED9C0), Color(0xFFD4A78A), Color(0xFF9A8AA8)];
  static const skyDay = [Color(0xFFEFE6D2), Color(0xFFC8D3DC), Color(0xFF8FA0B8)];
  static const skyDusk = [Color(0xFFE6967A), Color(0xFFA8748A), Color(0xFF3F3A52)];
  static const skyNight = [Color(0xFF1C2230), Color(0xFF0F1320), Color(0xFF06080F)];

  /// Mountain palette by element (五行 / Wǔxíng).
  static List<Color> mountainsForElement(WuxingElement el) => switch (el) {
        WuxingElement.wood => const [Color(0xFF4F6B53), Color(0xFF6E8E69), Color(0xFF8FAE85)],
        WuxingElement.fire => const [Color(0xFF7A2E25), Color(0xFFB83D2E), Color(0xFFD8674F)],
        WuxingElement.earth => const [Color(0xFF6B5A2E), Color(0xFFB8923D), Color(0xFFD8B66A)],
        WuxingElement.metal => const [Color(0xFF6B6E76), Color(0xFF9DA0AC), Color(0xFFD0D2DB)],
        WuxingElement.water => const [Color(0xFF1F3548), Color(0xFF3A5470), Color(0xFF6F88A1)],
      };
}

/// Five-element system. Used as note tags and to tint terrain.
enum WuxingElement {
  wood('木', '木'),
  fire('火', '火'),
  earth('土', '土'),
  metal('金', '金'),
  water('水', '水');

  final String glyph;
  final String label;
  const WuxingElement(this.glyph, this.label);
}
