import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../domain/parsing/vaccine_sticker_parser.dart';

class VaccineOcrService {
  const VaccineOcrService({this.parser = const VaccineStickerParser()});

  final VaccineStickerParser parser;

  Future<VaccineStickerRead> readFile(String path) async {
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
