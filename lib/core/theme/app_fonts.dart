import 'package:flutter/material.dart';

/// Static Noto Sans SC. The variable font's default instance is Thin, and
/// those hairline strokes paint as empty boxes. Every requested weight is
/// mapped onto the Regular or Bold file in pubspec so nothing falls through
/// to a system font that has no Chinese glyphs.
const zhuajiFamily = 'NotoSansSC';
const zhuajiFallback = <String>[zhuajiFamily];

const zhuaji = TextStyle(
  fontFamily: zhuajiFamily,
  fontFamilyFallback: zhuajiFallback,
);

FontWeight zhuajiWeight(FontWeight? weight) {
  final value = (weight ?? FontWeight.w400).value;
  return value >= FontWeight.w600.value ? FontWeight.w700 : FontWeight.w400;
}

TextStyle zhuajiOf(TextStyle? style) {
  return (style ?? const TextStyle()).copyWith(
    fontFamily: zhuajiFamily,
    fontFamilyFallback: zhuajiFallback,
    fontWeight: zhuajiWeight(style?.fontWeight),
  );
}
