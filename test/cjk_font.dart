import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget tests do not ship pubspec fonts or the engine icon fonts.
/// Load the full static faces and the full icon fonts. A tree-shaken
/// MaterialIcons subset passes layout tests and still paints boxes on device.
Future<void> loadZhuajiFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final override = Platform.environment['ZHUAJI_FONT_DIR'];
  if (override != null && override.isNotEmpty) {
    final dir = Directory(override);
    await _loadFamily('NotoSansSC', [
      File('${dir.path}/NotoSansSC-Regular.ttf'),
      File('${dir.path}/NotoSansSC-Bold.ttf'),
    ]);
    await _loadFamily('MaterialIcons', [
      File('${dir.path}/MaterialIcons-Regular.otf'),
    ]);
    final cupertino = File('${dir.path}/CupertinoIcons.ttf');
    await _loadFamily('CupertinoIcons', [cupertino]);
    await _loadFamily('packages/cupertino_icons/CupertinoIcons', [cupertino]);
    return;
  }

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

Future<void> _loadFamily(String family, List<File> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    if (!file.existsSync() || file.lengthSync() < 1000) {
      throw StateError('字体文件不可用：${file.path}');
    }
    final data = ByteData.sublistView(
      Uint8List.fromList(await file.readAsBytes()),
    );
    loader.addFont(Future<ByteData>.value(data));
  }
  await loader.load();
}

Future<void> _loadBytes(String family, Future<List<int>> bytes) async {
  final data = Uint8List.fromList(await bytes);
  if (data.length < 1000) {
    throw StateError('$family 字体过小（${data.length} 字节），像是被裁过的子集');
  }
  final loader = FontLoader(family)
    ..addFont(Future<ByteData>.value(ByteData.sublistView(data)));
  await loader.load();
}

Future<List<int>> _materialIconsBytes() async {
  final file = _materialIconsFile();
  if (!file.existsSync()) {
    throw StateError('找不到完整的 MaterialIcons-Regular.otf：${file.path}');
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
  final candidates = <File>[];
  try {
    final data = await rootBundle.load(
      'packages/cupertino_icons/assets/CupertinoIcons.ttf',
    );
    final bytes = data.buffer.asUint8List();
    if (bytes.length < 1000) {
      throw StateError('CupertinoIcons 资源过小');
    }
    for (final family in const [
      'CupertinoIcons',
      'packages/cupertino_icons/CupertinoIcons',
    ]) {
      final loader = FontLoader(family)..addFont(Future<ByteData>.value(data));
      await loader.load();
    }
    return;
  } catch (error) {
    final home = Platform.environment['HOME'] ?? '';
    final cache = Directory('$home/.pub-cache/hosted/pub.dev');
    if (cache.existsSync()) {
      candidates.addAll(
        cache
            .listSync()
            .whereType<Directory>()
            .where((dir) => dir.path.contains('cupertino_icons-'))
            .map((dir) => File('${dir.path}/assets/CupertinoIcons.ttf')),
      );
    }
    final file = candidates.cast<File?>().firstWhere(
      (item) => item!.existsSync() && item.lengthSync() > 1000,
      orElse: () => null,
    );
    if (file == null) {
      throw StateError('找不到完整的 CupertinoIcons.ttf（$error）');
    }
    final bytes = file.readAsBytes();
    await _loadBytes('CupertinoIcons', bytes);
    await _loadBytes(
      'packages/cupertino_icons/CupertinoIcons',
      file.readAsBytes(),
    );
  }
}
