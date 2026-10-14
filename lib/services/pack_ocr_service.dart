import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../domain/parsing/pack_front_parser.dart';

class PackOcrService {
  const PackOcrService({this.parser = const PackFrontParser()});

  final PackFrontParser parser;

  Future<PackRead> readFile(
    String path, {
    List<String> extraBrands = const [],
  }) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    try {
      final recognized = await recognizer.processImage(
        InputImage.fromFilePath(path),
      );
      return parser.parse(recognized.text, extraBrands: extraBrands);
    } finally {
      await recognizer.close();
    }
  }
}
