import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/core/theme/app_theme.dart';

import 'cjk_font.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Noto Sans SC draws Chinese strokes instead of tofu boxes', (
    tester,
  ) async {
    await tester.runAsync(loadZhuajiFonts);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: Key('glyph'),
              child: Text(
                '爪记喂食',
                style: TextStyle(fontSize: 40, color: Color(0xFF1E1E1E)),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('glyph')),
    );
    final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 1));
    final data = await tester.runAsync(
      () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
    );
    final ratio = interiorDarkRatio(data!, image!.width, image.height);
    expect(ratio, greaterThan(0.02));
  });

  testWidgets('Material icons draw glyphs instead of tofu boxes', (
    tester,
  ) async {
    await tester.runAsync(loadZhuajiFonts);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: Key('icons'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    size: 48,
                    color: Color(0xFF1E1E1E),
                  ),
                  Icon(Icons.home_outlined, size: 48, color: Color(0xFF1E1E1E)),
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 48,
                    color: Color(0xFF1E1E1E),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 48,
                    color: Color(0xFF1E1E1E),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('icons')),
    );
    final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 1));
    final data = await tester.runAsync(
      () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
    );
    final ratio = interiorDarkRatio(
      data!,
      image!.width,
      image.height,
      reason: 'Material icons painted no ink',
    );
    expect(ratio, greaterThan(0.08));
  });
}

double interiorDarkRatio(
  ByteData data,
  int width,
  int height, {
  String reason = 'Chinese sample painted no ink',
}) {
  bool darkAt(int x, int y) {
    final index = (y * width + x) * 4;
    final r = data.getUint8(index);
    final g = data.getUint8(index + 1);
    final b = data.getUint8(index + 2);
    final a = data.getUint8(index + 3);
    return a > 200 && (r + g + b) < 240;
  }

  var minX = width;
  var minY = height;
  var maxX = 0;
  var maxY = 0;
  var dark = 0;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      if (!darkAt(x, y)) continue;
      dark++;
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }
  }
  expect(dark, greaterThan(80), reason: reason);

  final insetX = ((maxX - minX) * 0.2).round();
  final insetY = ((maxY - minY) * 0.2).round();
  final x0 = minX + insetX;
  final x1 = maxX - insetX;
  final y0 = minY + insetY;
  final y1 = maxY - insetY;
  var interior = 0;
  var interiorDark = 0;
  for (var y = y0; y <= y1; y++) {
    for (var x = x0; x <= x1; x++) {
      interior++;
      if (darkAt(x, y)) interiorDark++;
    }
  }
  if (interior == 0) return 0;
  return interiorDark / interior;
}
