import '../dates.dart';
import 'ocr_lines.dart';

class OcrDateParseResult {
  const OcrDateParseResult({
    this.productionDate,
    this.expiryDate,
    this.shelfLifeText,
    this.expiryInferred = false,
    this.uncertain = false,
  });

  final DateTime? productionDate;
  final DateTime? expiryDate;
  final String? shelfLifeText;
  final bool expiryInferred;

  /// A date-like line was seen next to an expiry label, but the recognizer
  /// scored it too low to trust. Callers must leave the field empty.
  final bool uncertain;

  bool get hasDate => productionDate != null || expiryDate != null;
}

/// Pulls production / expiry dates out of OCR text printed on pet-food packs.
///
/// A date is accepted only next to a label, so a phone number is not a date.
/// “保质期 18 个月” or “shelf life 18 months” is applied when a production
/// date is also present. Year-last numbers on an expiry label are read as
/// day/month/year, which is how EXP and BBE are usually printed.
class OcrDateParser {
  const OcrDateParser();

  static final _ymd = RegExp(
    r'(\d{4})\s*[年\-/.]\s*(\d{1,2})\s*[月\-/.]\s*(\d{1,2})\s*日?',
  );
  static final _compact = RegExp(r'(?<!\d)(\d{4})(\d{2})(\d{2})(?!\d)');
  static final _numeric = RegExp(
    r'(?<!\d)(\d{1,2})\s*[./-]\s*(\d{1,2})\s*[./-]\s*(\d{2,4})(?!\d)',
  );
  static final _monthName = RegExp(
    r'(?<!\d)(\d{1,2})\s*[./\- ]?\s*'
    r'(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|'
    r'jul(?:y)?|aug(?:ust)?|sep(?:t(?:ember)?)?|oct(?:ober)?|'
    r'nov(?:ember)?|dec(?:ember)?)'
    r'\s*[./\- ]?\s*(\d{2,4})(?!\d)',
    caseSensitive: false,
  );
  static final _yearMonth = RegExp(r'(\d{4})\s*年\s*(\d{1,2})\s*月(?!\s*\d)');
  static final _shelfLife = RegExp(
    r'(?:保质期(?!至)|质保期|赏味期限|shelf\s*life)\s*[:：]?\s*(\d+)\s*'
    r'(年|个月|月|天|日|years?|months?|days?)',
    caseSensitive: false,
  );

  static const _months = {
    'jan': 1,
    'january': 1,
    'feb': 2,
    'february': 2,
    'mar': 3,
    'march': 3,
    'apr': 4,
    'april': 4,
    'may': 5,
    'jun': 6,
    'june': 6,
    'jul': 7,
    'july': 7,
    'aug': 8,
    'august': 8,
    'sep': 9,
    'sept': 9,
    'september': 9,
    'oct': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'dec': 12,
    'december': 12,
  };

  static const _productionLabels = ['生产日期', '制造日期', 'MFG', 'MFD', '生产'];
  static const _expiryLabels = [
    '到期时间',
    '到期日期',
    '到期日',
    '保质期至',
    '有效期至',
    '有效期限',
    '失效日期',
    '最佳赏味期',
    '此日期前最佳',
    'BEST BEFORE',
    'BEST BY',
    'USE BY',
    'EXPIRY DATE',
    'EXPIRY',
    'EXP DATE',
    'EXP. DATE',
    'BBE',
    'BBD',
    'EXP',
  ];

  /// Below this, a scored line is not turned into a date. Unscored lines
  /// (confidence == null) stay eligible when the label and the digits agree.
  static const confidenceFloor = 0.5;

  OcrDateParseResult parse(String raw) {
    final text = _normalize(raw);
    final lines = [
      for (final line in text.split(RegExp(r'\r?\n')))
        if (line.trim().isNotEmpty) OcrLine(line.trim()),
    ];
    if (lines.isEmpty) return const OcrDateParseResult();
    return parseLines(lines);
  }

  OcrDateParseResult parseLines(List<OcrLine> lines) {
    final segments = [
      for (final line in lines)
        if (line.text.trim().isNotEmpty)
          _Segment(_normalize(line.text.trim()), line.confidence),
    ];
    if (segments.isEmpty) return const OcrDateParseResult();
    final text = segments.map((segment) => segment.text).join('\n');
    var uncertain = false;
    final production = _findLabeledDate(
      segments,
      _productionLabels,
      dayFirst: false,
      onUncertain: () => uncertain = true,
    );
    final explicitExpiry = _findLabeledDate(
      segments,
      _expiryLabels,
      dayFirst: true,
      onUncertain: () => uncertain = true,
    );
    final shelf = _shelfLife.firstMatch(text);
    String? shelfText;
    DateTime? inferred;
    if (shelf != null && production != null) {
      final amount = int.parse(shelf.group(1)!);
      final unit = shelf.group(2)!;
      shelfText = '$amount$unit';
      inferred = _addShelf(production, amount, unit);
    } else if (shelf != null) {
      shelfText = '${shelf.group(1)}${shelf.group(2)}';
    }
    return OcrDateParseResult(
      productionDate: production,
      expiryDate: explicitExpiry ?? inferred,
      shelfLifeText: shelfText,
      expiryInferred: explicitExpiry == null && inferred != null,
      uncertain: uncertain && explicitExpiry == null && inferred == null,
    );
  }

  DateTime _addShelf(DateTime production, int amount, String unit) {
    final normalized = unit.toLowerCase();
    if (normalized == '年' || normalized.startsWith('year')) {
      return addMonths(production, amount * 12);
    }
    if (normalized == '个月' ||
        normalized == '月' ||
        normalized.startsWith('month')) {
      return addMonths(production, amount);
    }
    return production.add(Duration(days: amount));
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

  DateTime? _findLabeledDate(
    List<_Segment> segments,
    List<String> labels, {
    required bool dayFirst,
    required void Function() onUncertain,
  }) {
    for (final label in labels) {
      final needle = label.toUpperCase();
      for (var i = 0; i < segments.length; i++) {
        final segment = segments[i];
        final upper = segment.text.toUpperCase();
        var from = 0;
        while (true) {
          final index = upper.indexOf(needle, from);
          if (index < 0) break;
          final after = index + needle.length;
          if (_insideWord(upper, index, after)) {
            from = after;
            continue;
          }
          final rest = segment.text.substring(after);
          final onLine = _readDate(_window(rest), dayFirst: dayFirst);
          if (onLine != null) {
            if (!segment.trusted) {
              onUncertain();
              from = after;
              continue;
            }
            return onLine;
          }
          if (i + 1 < segments.length &&
              !_startsWithAnyLabel(segments[i + 1].text)) {
            final next = segments[i + 1];
            final nextDate = _readDate(
              _window(next.text),
              dayFirst: dayFirst,
            );
            if (nextDate != null) {
              if (!segment.trusted || !next.trusted) {
                onUncertain();
                from = after;
                continue;
              }
              return nextDate;
            }
          }
          from = after;
        }
      }
    }
    return null;
  }

  bool _insideWord(String upper, int start, int end) {
    if (end >= upper.length) return false;
    final next = upper.codeUnitAt(end);
    final letter = next >= 65 && next <= 90;
    if (!letter) return false;
    if (start > 0) {
      final prev = upper.codeUnitAt(start - 1);
      if (prev >= 65 && prev <= 90) return true;
    }
    return end - start <= 4;
  }

  bool _startsWithAnyLabel(String text) {
    final trimmed = text.trim().toUpperCase();
    const labels = [..._productionLabels, ..._expiryLabels, '保质期', 'SHELF LIFE'];
    for (final label in labels) {
      if (trimmed.startsWith(label.toUpperCase())) return true;
    }
    return false;
  }

  String _window(String line) {
    final trimmed = line.trim();
    return trimmed.length > 64 ? trimmed.substring(0, 64) : trimmed;
  }

  DateTime? _readDate(String window, {required bool dayFirst}) {
    final found = <(int, DateTime)>[];
    void add(RegExpMatch? match, DateTime? date) {
      if (match != null && date != null) found.add((match.start, date));
    }

    final ymd = _ymd.firstMatch(window);
    if (ymd != null) {
      add(
        ymd,
        parseCalendarDate(
          int.parse(ymd.group(1)!),
          int.parse(ymd.group(2)!),
          int.parse(ymd.group(3)!),
        ),
      );
    }
    final named = _monthName.firstMatch(window);
    if (named != null) {
      final month = _months[named.group(2)!.toLowerCase()];
      add(
        named,
        month == null
            ? null
            : parseCalendarDate(
                _expandYear(int.parse(named.group(3)!)),
                month,
                int.parse(named.group(1)!),
              ),
      );
    }
    final numeric = _numeric.firstMatch(window);
    if (numeric != null) {
      final first = int.parse(numeric.group(1)!);
      final second = int.parse(numeric.group(2)!);
      final year = _expandYear(int.parse(numeric.group(3)!));
      final preferDay = dayFirst || first > 12;
      final month = preferDay ? second : first;
      final day = preferDay ? first : second;
      final resolvedMonth = second > 12 ? first : month;
      final resolvedDay = second > 12 ? second : day;
      add(numeric, parseCalendarDate(year, resolvedMonth, resolvedDay));
    }
    final compact = _compact.firstMatch(window);
    if (compact != null) {
      add(
        compact,
        parseCalendarDate(
          int.parse(compact.group(1)!),
          int.parse(compact.group(2)!),
          int.parse(compact.group(3)!),
        ),
      );
    }
    final yearMonth = _yearMonth.firstMatch(window);
    if (yearMonth != null) {
      final year = int.parse(yearMonth.group(1)!);
      final month = int.parse(yearMonth.group(2)!);
      if (month >= 1 && month <= 12) {
        final last = DateTime(year, month + 1, 0).day;
        add(yearMonth, parseCalendarDate(year, month, last));
      }
    }
    if (found.isEmpty) return null;
    found.sort((a, b) => a.$1.compareTo(b.$1));
    return found.first.$2;
  }

  int _expandYear(int year) {
    if (year >= 100) return year;
    return year >= 70 ? 1900 + year : 2000 + year;
  }
}

class _Segment {
  const _Segment(this.text, this.confidence);

  final String text;
  final double? confidence;

  bool get trusted =>
      confidence == null || confidence! >= OcrDateParser.confidenceFloor;
}
