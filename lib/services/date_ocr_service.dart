import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../domain/parsing/ocr_date_parser.dart';

class DateOcrService {
  const DateOcrService({this.parser = const OcrDateParser()});

  final OcrDateParser parser;

  Future<OcrDateParseResult> readFile(String path) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    try {
      final recognized = await recognizer.processImage(
        InputImage.fromFilePath(path),
      );
      return parser.parse(recognized.text);
    } finally {
      await recognizer.close();
    }
  }
}
