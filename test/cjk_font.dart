import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget tests do not apply fonts from pubspec. Load the same static
/// Noto Sans SC files the app registers, or CJK paints as empty boxes.
Future<void> loadZhuajiFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loader = FontLoader('NotoSansSC');
  for (final asset in const [
    'assets/fonts/NotoSansSC-Regular.ttf',
    'assets/fonts/NotoSansSC-Bold.ttf',
  ]) {
    loader.addFont(rootBundle.load(asset));
  }
  await loader.load();
}
