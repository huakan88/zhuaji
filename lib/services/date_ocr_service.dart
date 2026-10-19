import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../domain/parsing/ocr_date_parser.dart';
import 'lab_ocr_service.dart';

/// Same on-device ML Kit recognizer as pack photos. Line scores are kept
/// so a low-confidence expiry is left blank instead of guessed.
class DateOcrService {
  const DateOcrService({this.parser = const OcrDateParser()});

  final OcrDateParser parser;

  Future<OcrDateParseResult> readFile(String path) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    try {
      final recognized = await recognizer.processImage(
        InputImage.fromFilePath(path),
      );
      final lines = ocrLinesOf(recognized);
      if (lines.isEmpty) return const OcrDateParseResult();
      return parser.parseLines(lines);
    } finally {
      await recognizer.close();
    }
  }
}
