import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const background = Color(0xFFFAFAF8);
  static const ink = Color(0xFF1E1E1E);
  static const muted = Color(0xFF666666);
  static const coral = Color(0xFFFFBFA3);
  static const coralDeep = Color(0xFFF09A78);
  static const green = Color(0xFFBCE67B);
  static const sage = Color(0xFF8FA882);
  static const olive = Color(0xFF5C6B4A);
  static const brown = Color(0xFF8C6A52);
  static const cream = Color(0xFFF6F1E8);
  static const line = Color(0xFFE7E2DA);
  static const card = Color(0xFFFFFFFF);
  static const danger = Color(0xFFC45C4A);
  static const tintCoral = Color(0xFFFFF1EA);
  static const tintGreen = Color(0xFFF4F8EA);
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

  static const s = 8.0;
  static const m = 12.0;
  static const l = 16.0;
  static const xl = 20.0;
}

const softShadow = [
  BoxShadow(color: Color(0x141E1E1E), blurRadius: 24, offset: Offset(0, 8)),
];

const ringPalette = [
  AppColors.coral,
  AppColors.green,
  AppColors.sage,
  AppColors.brown,
];
