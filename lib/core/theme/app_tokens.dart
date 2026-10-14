import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const background = Color(0xFFF6F1EA);
  static const ink = Color(0xFF2C2A28);
  static const muted = Color(0xFF8A8178);
  static const coral = Color(0xFFF6B39A);
  static const coralDeep = Color(0xFFE58B72);
  static const green = Color(0xFFD5E6B5);
  static const sage = Color(0xFF8E9B86);
  static const olive = Color(0xFF5E6B52);
  static const brown = Color(0xFF8C6A52);
  static const cream = Color(0xFFF3EBE1);
  static const line = Color(0xFFE7DFD4);
  static const card = Color(0xFFFFFFFF);
  static const danger = Color(0xFFC45C4A);
  static const tintCoral = Color(0xFFFFE8DE);
  static const tintGreen = Color(0xFFF1F6E6);
  static const tintSage = Color(0xFFE4EBE0);
  static const tintBrown = Color(0xFFF3E4D6);
  static const tintOlive = Color(0xFFE6EBD8);
  static const tintRose = Color(0xFFF8E4DE);
  static const headerStart = Color(0xFFFFF8F3);
  static const headerMid = Color(0xFFF6D7C8);
  static const headerEnd = Color(0xFFE4EDE0);
}

const headerGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.headerStart, AppColors.headerMid, AppColors.headerEnd],
);

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

  static const s = 12.0;
  static const m = 16.0;
  static const l = 20.0;
  static const xl = 28.0;
}

const softShadow = <BoxShadow>[
  BoxShadow(color: Color(0x1F8C6A52), blurRadius: 22, offset: Offset(0, 10)),
  BoxShadow(color: Color(0x0F2C2A28), blurRadius: 4, offset: Offset(0, 1)),
];

const scanGlow = <BoxShadow>[
  BoxShadow(
    color: Color(0x80F6B39A),
    blurRadius: 22,
    spreadRadius: 2,
    offset: Offset(0, 8),
  ),
  BoxShadow(color: Color(0x40E58B72), blurRadius: 32, spreadRadius: 8),
];

const ringPalette = [
  AppColors.coral,
  AppColors.green,
  AppColors.sage,
  AppColors.brown,
];
