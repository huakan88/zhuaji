import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../domain/parsing/pack_front_parser.dart';
import 'lab_ocr_service.dart';

/// On-device OCR for pack photos.
///
/// Google ML Kit Text Recognition (`google_mlkit_text_recognition`, Chinese
/// script) already ships in this app. It runs on the phone, reads Chinese and
/// Latin, and does not need a cloud key. PaddleOCR mobile and Tesseract were
/// not added: Paddle needs a large bundled model, and the maintained Tesseract
/// plugins are weaker on Chinese pack type. ML Kit stays; the parser maps
/// each labeled line into its own field.
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
      final lines = ocrLinesOf(recognized);
      return parser.parse(
        recognized.text,
        extraBrands: extraBrands,
        lines: lines,
      );
    } finally {
      await recognizer.close();
    }
  }
}
