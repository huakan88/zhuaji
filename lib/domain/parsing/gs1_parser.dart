import '../dates.dart';

class Gs1ParseResult {
  const Gs1ParseResult({
    this.productionDate,
    this.expiryDate,
    this.bestBeforeDate,
    this.batch,
    this.gtin,
  });

  final DateTime? productionDate;
  final DateTime? expiryDate;
  final DateTime? bestBeforeDate;
  final String? batch;
  final String? gtin;

  bool get recognized =>
      productionDate != null ||
      expiryDate != null ||
      bestBeforeDate != null ||
      (batch != null && batch!.isNotEmpty) ||
      (gtin != null && gtin!.isNotEmpty);

  /// Expiry shown to the user. AI 17 wins; AI 15 is only a best-before hint.
  DateTime? get suggestedExpiry => expiryDate ?? bestBeforeDate;

  bool get expiryIsBestBefore => expiryDate == null && bestBeforeDate != null;
}

/// Parses GS1 element strings from DataMatrix / QR scans.
///
/// Supports the human-readable form `(11)251012(17)270412(10)LOT`
/// and raw element strings split by the GS separator (ASCII 29).
/// EAN/UPC product codes are not dates and return an empty result.
class Gs1Parser {
  const Gs1Parser();

  static const _fixedLength = <String, int>{
    '00': 18,
    '01': 14,
    '02': 14,
    '11': 6,
    '12': 6,
    '13': 6,
    '15': 6,
    '16': 6,
    '17': 6,
  };

  static final _parentheses = RegExp(r'\((\d{2,4})\)\s*([^(]*)');
  static final _symbology = RegExp(r'^\][A-Za-z]\d');

  Gs1ParseResult parse(String raw, {DateTime? reference}) {
    var text = raw.trim();
    if (text.isEmpty) return const Gs1ParseResult();
    if (_symbology.hasMatch(text)) {
      text = text.replaceFirst(_symbology, '');
    }
    text = text.replaceAll('<GS>', '\u001d').replaceAll('<FNC1>', '\u001d');

    final result = _Accumulator(reference ?? DateTime.now());
    if (text.contains('(')) {
      for (final match in _parentheses.allMatches(text)) {
        result.apply(match.group(1)!, match.group(2) ?? '');
      }
    } else {
      for (final segment in text.split('\u001d')) {
        _consumeElement(segment.trim(), result);
      }
    }
    return result.toResult();
  }

  void _consumeElement(String segment, _Accumulator result) {
    if (segment.isEmpty) return;
    var index = 0;
    while (index + 2 <= segment.length) {
      final ai = segment.substring(index, index + 2);
      final fixed = _fixedLength[ai];
      if (fixed != null) {
        if (index + 2 + fixed > segment.length) return;
        result.apply(ai, segment.substring(index + 2, index + 2 + fixed));
        index += 2 + fixed;
        continue;
      }
      if (ai == '10' || ai == '21') {
        result.apply(ai, segment.substring(index + 2));
        return;
      }
      return;
    }
  }
}

class _Accumulator {
  _Accumulator(this.reference);

  final DateTime reference;
  DateTime? productionDate;
  DateTime? expiryDate;
  DateTime? bestBeforeDate;
  String? batch;
  String? gtin;

  void apply(String ai, String rawValue) {
    final value = rawValue.replaceAll('\u001d', '').trim();
    switch (ai) {
      case '11':
        productionDate = parseGs1Date(value, reference: reference);
      case '17':
        expiryDate = parseGs1Date(value, reference: reference);
      case '15':
        bestBeforeDate = parseGs1Date(value, reference: reference);
      case '10':
      case '21':
        if (value.isNotEmpty) batch = value;
      case '01':
        final digits = value.replaceAll(RegExp(r'\D'), '');
        if (digits.length >= 8) gtin = digits;
    }
  }

  Gs1ParseResult toResult() => Gs1ParseResult(
    productionDate: productionDate,
    expiryDate: expiryDate,
    bestBeforeDate: bestBeforeDate,
    batch: batch,
    gtin: gtin,
  );
}
