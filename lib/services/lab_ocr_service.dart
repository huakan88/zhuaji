import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../domain/models.dart';
import '../domain/parsing/lab_report_parser.dart';
import '../domain/parsing/ocr_lines.dart';

class LabOcrService {
  const LabOcrService({this.parser = const LabReportParser()});

  final LabReportParser parser;

  Future<List<LabValue>> readFiles(List<String> paths) async {
    if (paths.isEmpty) return const [];
    final recognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    try {
      final lines = <OcrLine>[];
      for (final path in paths) {
        final recognized = await recognizer.processImage(
          InputImage.fromFilePath(path),
        );
        lines.addAll(ocrLinesOf(recognized));
      }
      return parser.parse(OcrText(lines));
    } finally {
      await recognizer.close();
    }
  }
}

List<OcrLine> ocrLinesOf(RecognizedText recognized) {
  final lines = <OcrLine>[];
  for (final block in recognized.blocks) {
    for (final line in block.lines) {
      final box = line.boundingBox;
      lines.add(
        OcrLine(
          line.text,
          left: box.left.toDouble(),
          top: box.top.toDouble(),
          right: box.right.toDouble(),
          bottom: box.bottom.toDouble(),
          confidence: line.confidence,
        ),
      );
    }
  }
  if (lines.isEmpty && recognized.text.trim().isNotEmpty) {
    return [OcrLine(recognized.text)];
  }
  return lines;
}
