/// One recognized text line with its box in image pixels.
class OcrLine {
  const OcrLine(
    this.text, {
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
    this.confidence,
  });

  final String text;
  final double left;
  final double top;
  final double right;
  final double bottom;

  /// 0–1 from the recognizer. Null means the engine did not score the line.
  final double? confidence;

  double get height => bottom - top;
  double get centerY => (top + bottom) / 2;
  bool get hasBox => bottom > top;
}

class OcrText {
  const OcrText(this.lines);

  final List<OcrLine> lines;

  String get plain => lines.map((line) => line.text).join('\n');

  bool get isEmpty => lines.every((line) => line.text.trim().isEmpty);
}

/// Table cells come back as separate lines. Lines whose vertical centers sit
/// within half a line height are one printed row, read left to right.
List<String> rowsFromLines(List<OcrLine> lines) {
  final boxed = [
    for (final line in lines)
      if (line.text.trim().isNotEmpty) line,
  ];
  if (boxed.isEmpty) return const [];
  if (boxed.any((line) => !line.hasBox)) {
    return [for (final line in boxed) line.text.trim()];
  }
  final sorted = [...boxed]..sort((a, b) => a.centerY.compareTo(b.centerY));
  final rows = <List<OcrLine>>[];
  for (final line in sorted) {
    final row = rows.isEmpty ? null : rows.last;
    if (row != null) {
      final center =
          row.fold<double>(0, (sum, item) => sum + item.centerY) / row.length;
      final height =
          row.fold<double>(0, (sum, item) => sum + item.height) / row.length;
      final tolerance = (height < line.height ? height : line.height) * 0.5;
      if ((line.centerY - center).abs() <= tolerance) {
        row.add(line);
        continue;
      }
    }
    rows.add([line]);
  }
  return [
    for (final row in rows)
      ([...row]..sort((a, b) => a.left.compareTo(b.left)))
          .map((line) => line.text.trim())
          .join('  '),
  ];
}

/// Full-width digits, letters and punctuation become ASCII.
String halfWidth(String raw) {
  final buffer = StringBuffer();
  for (final rune in raw.runes) {
    if (rune >= 0xFF01 && rune <= 0xFF5E) {
      buffer.writeCharCode(rune - 0xFEE0);
    } else if (rune == 0x3000) {
      buffer.write(' ');
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer
      .toString()
      .replaceAll(RegExp('[～~–—−一]'), '-')
      .replaceAll('，', ',')
      .replaceAll('：', ':')
      .replaceAll('。', '.');
}
