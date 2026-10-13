import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget tests do not apply fonts from pubspec or the engine icon fonts.
/// Without these loads, Chinese and Material icons both paint as empty boxes.
Future<void> loadZhuajiFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final noto = FontLoader('NotoSansSC');
  for (final asset in const [
    'assets/fonts/NotoSansSC-Regular.ttf',
    'assets/fonts/NotoSansSC-Bold.ttf',
  ]) {
    noto.addFont(rootBundle.load(asset));
  }
  await noto.load();
  await _loadBytes('MaterialIcons', _materialIconsBytes());
  await _loadCupertinoIcons();
}

Future<void> _loadBytes(String family, Future<List<int>> bytes) async {
  final data = Uint8List.fromList(await bytes);
  final loader = FontLoader(family)
    ..addFont(Future<ByteData>.value(ByteData.sublistView(data)));
  await loader.load();
}

Future<List<int>> _materialIconsBytes() async {
  final file = _materialIconsFile();
  if (!file.existsSync()) {
    throw StateError('找不到 MaterialIcons-Regular.otf：${file.path}');
  }
  return file.readAsBytes();
}

File _materialIconsFile() {
  final roots = <String>[
    if ((Platform.environment['FLUTTER_ROOT'] ?? '').isNotEmpty)
      Platform.environment['FLUTTER_ROOT']!,
  ];
  final which = Process.runSync('which', ['flutter']);
  if (which.exitCode == 0) {
    final bin = File((which.stdout as String).trim());
    if (bin.existsSync()) roots.add(bin.parent.parent.path);
  }
  for (final root in roots) {
    final file = File(
      '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (file.existsSync()) return file;
  }
  return File(
    '${roots.isEmpty ? '' : roots.first}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
}

Future<void> _loadCupertinoIcons() async {
  try {
    final data = await rootBundle.load(
      'packages/cupertino_icons/assets/CupertinoIcons.ttf',
    );
    final loader = FontLoader('CupertinoIcons')
      ..addFont(Future<ByteData>.value(data));
    await loader.load();
  } catch (_) {
    final which = Process.runSync('which', ['flutter']);
    if (which.exitCode != 0) return;
    final home = Platform.environment['HOME'] ?? '';
    final file = File(
      '$home/.pub-cache/hosted/pub.dev/cupertino_icons-1.0.9/assets/CupertinoIcons.ttf',
    );
    if (file.existsSync()) {
      await _loadBytes('CupertinoIcons', file.readAsBytes());
    }
  }
}
