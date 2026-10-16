import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/core/theme/app_tokens.dart';

void main() {
  test('pages do not hardcode colors', () {
    const allow = {
      'lib/core/theme/app_tokens.dart',
      'android/app/src/main/res/values/colors.xml',
      'android/app/src/main/res/values-night/colors.xml',
    };
    final bad = <String>[];
    for (final root in [
      Directory('lib'),
      Directory('android/app/src'),
      Directory('ios'),
    ]) {
      if (!root.existsSync()) continue;
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File) continue;
        final path = entity.path.replaceAll('\\', '/');
        if (path.contains('.xcassets/')) continue;
        final ext = path.split('.').last;
        if (!{'dart', 'xml', 'kt', 'swift'}.contains(ext)) continue;
        if (allow.contains(path)) continue;
        final text = entity.readAsStringSync();
        if (RegExp('coral', caseSensitive: false).hasMatch(text)) {
          bad.add('$path coral');
        }
        if (RegExp(r'(?<![\w.])Colors\.').hasMatch(text)) {
          bad.add('$path Colors.');
        }
        if (RegExp(r'''(?<![\w.])Color\s*\(\s*(?!["'])''').hasMatch(text)) {
          bad.add('$path Color(');
        }
        if (RegExp(r'#[0-9A-Fa-f]{3,8}\b').hasMatch(text)) {
          bad.add('$path hex');
        }
      }
    }
    expect(bad, isEmpty);
  });

  test('text pairs stay at WCAG AA', () {
    void check(String name, Color ink, Color ground) {
      expect(_ratio(ink, ground), greaterThanOrEqualTo(4.5), reason: name);
    }

    final pairs = <(String, Color, Color)>[
      ('light ink/background', AppColors.light.ink, AppColors.light.background),
      (
        'light muted/background',
        AppColors.light.muted,
        AppColors.light.background,
      ),
      ('light ink/card', AppColors.light.ink, AppColors.light.card),
      ('light muted/card', AppColors.light.muted, AppColors.light.card),
      ('light onBrand/brand', AppColors.light.onBrand, AppColors.light.brand),
      (
        'light danger/tintDanger',
        AppColors.light.danger,
        AppColors.light.tintDanger,
      ),
      (
        'light warning/tintWarning',
        AppColors.light.warning,
        AppColors.light.tintWarning,
      ),
      ('light low/tintLow', AppColors.light.low, AppColors.light.tintLow),
      (
        'light olive/tintOlive',
        AppColors.light.olive,
        AppColors.light.tintOlive,
      ),
      ('light ink/field', AppColors.light.ink, AppColors.light.field),
      ('dark ink/background', AppColors.dark.ink, AppColors.dark.background),
      (
        'dark muted/background',
        AppColors.dark.muted,
        AppColors.dark.background,
      ),
      ('dark ink/card', AppColors.dark.ink, AppColors.dark.card),
      ('dark muted/card', AppColors.dark.muted, AppColors.dark.card),
      ('dark onBrand/brand', AppColors.dark.onBrand, AppColors.dark.brand),
      (
        'dark danger/tintDanger',
        AppColors.dark.danger,
        AppColors.dark.tintDanger,
      ),
      (
        'dark warning/tintWarning',
        AppColors.dark.warning,
        AppColors.dark.tintWarning,
      ),
      ('dark low/tintLow', AppColors.dark.low, AppColors.dark.tintLow),
      ('dark olive/tintOlive', AppColors.dark.olive, AppColors.dark.tintOlive),
      ('dark ink/field', AppColors.dark.ink, AppColors.dark.field),
      ('light snack', AppColors.light.snackAction, AppColors.light.ink),
      ('dark snack', AppColors.dark.snackAction, AppColors.dark.ink),
      ('light hint/field', AppColors.light.muted, AppColors.light.field),
      ('dark hint/field', AppColors.dark.muted, AppColors.dark.field),
      ('light pill muted', AppColors.light.muted, AppColors.light.brandTint),
      ('dark pill muted', AppColors.dark.muted, AppColors.dark.brandTint),
      (
        'light pill count',
        AppColors.light.brandDeep,
        AppColors.light.brandTint,
      ),
      ('dark pill count', AppColors.dark.brandDeep, AppColors.dark.brandTint),
      ('light text button', AppColors.light.olive, AppColors.light.background),
      ('dark text button', AppColors.dark.olive, AppColors.dark.background),
      ('dark warm/card', AppColors.dark.warm, AppColors.dark.card),
      ('scrim text', AppColors.light.onScrim, AppColors.light.scrim),
      ('scrim muted', AppColors.light.onScrimMuted, AppColors.light.scrim),
      ('dark scrim muted', AppColors.dark.onScrimMuted, AppColors.dark.scrim),
    ];
    for (final (name, ink, ground) in pairs) {
      check(name, ink, ground);
    }
  });
}

double _channel(double value) {
  return value <= 0.04045
      ? value / 12.92
      : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
}

double _luminance(Color color) {
  return 0.2126 * _channel(color.r) +
      0.7152 * _channel(color.g) +
      0.0722 * _channel(color.b);
}

double _ratio(Color a, Color b) {
  final left = _luminance(a);
  final right = _luminance(b);
  final lighter = math.max(left, right);
  final darker = math.min(left, right);
  return (lighter + 0.05) / (darker + 0.05);
}
