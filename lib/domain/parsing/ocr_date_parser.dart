import '../dates.dart';

class OcrDateParseResult {
  const OcrDateParseResult({
    this.productionDate,
    this.expiryDate,
    this.shelfLifeText,
    this.expiryInferred = false,
  });

  final DateTime? productionDate;
  final DateTime? expiryDate;
  final String? shelfLifeText;
  final bool expiryInferred;

  bool get hasDate => productionDate != null || expiryDate != null;
}

/// Pulls production / expiry dates out of OCR text printed on pet-food packs.
///
/// Dates are only accepted next to a label (生产日期, EXP, …) so stray
/// numbers are not treated as dates. A relative shelf life such as
/// “保质期 18 个月” is applied when a production date is also present.
class OcrDateParser {
  const OcrDateParser();

  static final _ymd = RegExp(
    r'(\d{4})\s*[年\-/.]\s*(\d{1,2})\s*[月\-/.]\s*(\d{1,2})\s*日?',
  );
  static final _compact = RegExp(r'(?<!\d)(\d{4})(\d{2})(\d{2})(?!\d)');
  static final _shelfLife = RegExp(r'保质期(?!至)[:：]?\s*(\d+)\s*(年|个月|月|天|日)');

  static const _productionLabels = ['生产日期', '制造日期', 'MFG', 'MFD', '生产'];
  static const _expiryLabels = [
    '保质期至',
    '有效期至',
    '失效日期',
    '到期日期',
    '最佳赏味期',
    '此日期前最佳',
    'EXPIRY',
    'EXP',
    'BBD',
  ];

  OcrDateParseResult parse(String raw) {
    final text = _normalize(raw);
    final production = _findLabeledDate(text, _productionLabels);
    final explicitExpiry = _findLabeledDate(text, _expiryLabels);
    final shelf = _shelfLife.firstMatch(text);
    String? shelfText;
    DateTime? inferred;
    if (shelf != null) {
      final amount = int.parse(shelf.group(1)!);
      final unit = shelf.group(2)!;
      shelfText = '$amount$unit';
      if (production != null) {
        inferred = switch (unit) {
          '年' => addMonths(production, amount * 12),
          '个月' || '月' => addMonths(production, amount),
          _ => production.add(Duration(days: amount)),
        };
      }
    }
    return OcrDateParseResult(
      productionDate: production,
      expiryDate: explicitExpiry ?? inferred,
      shelfLifeText: shelfText,
      expiryInferred: explicitExpiry == null && inferred != null,
    );
  }

  String _normalize(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0xFF10 && rune <= 0xFF19) {
        buffer.writeCharCode(0x30 + (rune - 0xFF10));
      } else if (rune == 0xFF0D || rune == 0x2013 || rune == 0x2014) {
        buffer.write('-');
      } else if (rune == 0xFF0F) {
        buffer.write('/');
      } else if (rune == 0xFF0E) {
        buffer.write('.');
      } else if (rune == 0xFF1A) {
        buffer.write(':');
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  DateTime? _findLabeledDate(String text, List<String> labels) {
    final upper = text.toUpperCase();
    for (final label in labels) {
      var from = 0;
      final needle = label.toUpperCase();
      while (true) {
        final index = upper.indexOf(needle, from);
        if (index < 0) break;
        final rest = text.substring(index + label.length);
        final lineBreak = rest.indexOf('\n');
        final line = lineBreak == -1 ? rest : rest.substring(0, lineBreak);
        final window = line.length > 40 ? line.substring(0, 40) : line;
        final date = _readDate(window);
        if (date != null) return date;
        from = index + needle.length;
      }
    }
    return null;
  }

  DateTime? _readDate(String window) {
    final found = <(int, DateTime)>[];
    final ymd = _ymd.firstMatch(window);
    if (ymd != null) {
      final date = parseCalendarDate(
        int.parse(ymd.group(1)!),
        int.parse(ymd.group(2)!),
        int.parse(ymd.group(3)!),
      );
      if (date != null) found.add((ymd.start, date));
    }
    final compact = _compact.firstMatch(window);
    if (compact != null) {
      final date = parseCalendarDate(
        int.parse(compact.group(1)!),
        int.parse(compact.group(2)!),
        int.parse(compact.group(3)!),
      );
      if (date != null) found.add((compact.start, date));
    }
    if (found.isEmpty) return null;
    found.sort((a, b) => a.$1.compareTo(b.$1));
    return found.first.$2;
  }
}
