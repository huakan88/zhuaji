import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const background = Color(0xFFF7F5F2);
  static const ink = Color(0xFF1F1E1C);
  static const muted = Color(0xFF8A8682);
  static const coral = Color(0xFFE7A090);
  static const coralDeep = Color(0xFFD48978);
  static const green = Color(0xFFD7E4D2);
  static const sage = Color(0xFFA9B8A4);
  static const olive = Color(0xFF6D7B68);
  static const brown = Color(0xFF8C6A52);
  static const cream = Color(0xFFF3EEE8);
  static const line = Color(0xFFE7E2DC);
  static const card = Color(0xFFFFFFFF);
  static const danger = Color(0xFFC45C4A);
  static const tintCoral = Color(0xFFF8EBE6);
  static const tintGreen = Color(0xFFF1F5EF);
  static const tintSage = Color(0xFFEEF2EC);
  static const tintBrown = Color(0xFFF6F0EA);
  static const tintOlive = Color(0xFFF3F5EF);
  static const tintRose = Color(0xFFF8EEEA);
}

class Space {
  const Space._();

  static const x1 = 4.0;
  static const x2 = 8.0;
  static const x3 = 12.0;
  static const x4 = 16.0;
  static const x5 = 20.0;
  static const x6 = 24.0;
  static const x8 = 32.0;
}

class Radii {
  const Radii._();

  static const s = 14.0;
  static const m = 16.0;
  static const l = 20.0;
  static const xl = 24.0;
}

const softShadow = <BoxShadow>[
  BoxShadow(color: Color(0x0F1F1E1C), blurRadius: 12, offset: Offset(0, 4)),
];

const ringPalette = [
  AppColors.coral,
  AppColors.sage,
  AppColors.tintCoral,
  AppColors.brown,
];
