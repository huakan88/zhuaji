import '../health/lab_catalog.dart';
import '../models.dart';
import 'ocr_lines.dart';

/// Pulls common feline CBC and chemistry numbers out of OCR text.
/// A row with no readable number is skipped; the user fills that one by tapping.
class LabReportParser {
  const LabReportParser();

  List<LabValue> parse(OcrText text) {
    final found = <String, LabValue>{};
    for (final row in rowsFromLines(text.lines)) {
      final hit = parseRow(row);
      if (hit == null) continue;
      found.putIfAbsent(hit.code, () => hit);
    }
    return [
      for (final item in labCatalog)
        if (found.containsKey(item.code)) found[item.code]!,
    ];
  }

  List<LabValue> parsePlain(String raw) {
    final lines = [
      for (final line in raw.split(RegExp(r'\r?\n')))
        if (line.trim().isNotEmpty) OcrLine(line.trim()),
    ];
    return parse(OcrText(lines));
  }

  /// One printed row. Returns null when the analyte or the number is missing,
  /// and when the row is a percentage differential rather than a count.
  LabValue? parseRow(String raw) {
    final row = halfWidth(raw).trim();
    if (row.isEmpty) return null;
    final hit = _bestAlias(row);
    if (hit == null) return null;
    final percent = _isPercent(row, hit.end);
    final allowsPercent = hit.analyte.units.any((unit) => unit.label == '%');
    if (percent && !allowsPercent) return null;

    final range = _range(row);
    final unit = _unit(row, hit.analyte, range);
    final stripped = _hideUnitTokens(row);
    final blocked = <_Span>[
      ?range,
      if (unit != null && unit.end > unit.start) unit,
    ];
    final number = _resultNumber(stripped, hit.end, blocked);
    if (number == null) return null;
    final unitLabel = unit?.label ?? inferLabUnit(hit.analyte, number);
    return LabValue(
      code: hit.analyte.code,
      value: number,
      unit: unitLabel,
      printedLow: range?.low,
      printedHigh: range?.high,
    );
  }
}

class _AliasHit {
  const _AliasHit(this.analyte, this.end);
  final LabAnalyte analyte;
  final int end;
}

class _Span {
  const _Span(this.start, this.end, {this.low, this.high, this.label});
  final int start;
  final int end;
  final double? low;
  final double? high;
  final String? label;
}

_AliasHit? _bestAlias(String row) {
  final aliases = <(LabAnalyte, String)>[
    for (final item in labCatalog)
      for (final alias in item.aliases) (item, alias),
  ]..sort((a, b) => b.$2.length.compareTo(a.$2.length));
  final occupied = <_Span>[];
  _AliasHit? best;
  var bestStart = 1 << 30;
  var bestLength = 0;
  for (final (analyte, alias) in aliases) {
    final found = _indexOf(row, alias);
    if (found < 0) continue;
    final end = found + ( _ascii(alias) ? alias.length : alias.length);
    final span = _Span(found, found + alias.length);
    if (occupied.any((item) => item.start < span.end && span.start < item.end)) {
      continue;
    }
    occupied.add(span);
    if (found < bestStart || (found == bestStart && alias.length > bestLength)) {
      bestStart = found;
      bestLength = alias.length;
      best = _AliasHit(analyte, end);
    }
  }
  return best;
}

bool _ascii(String alias) => RegExp(r'^[A-Za-z0-9#+\-]+$').hasMatch(alias);

int _indexOf(String row, String alias) {
  final ascii = _ascii(alias);
  final hay = ascii ? row.toUpperCase() : row;
  final needle = ascii ? alias.toUpperCase() : alias;
  var from = 0;
  while (from < hay.length) {
    final index = hay.indexOf(needle, from);
    if (index < 0) return -1;
    if (_boundary(hay, needle, index)) return index;
    from = index + 1;
  }
  return -1;
}

bool _boundary(String row, String needle, int index) {
  if (!_ascii(needle)) return true;
  if (index > 0 && RegExp(r'[A-Za-z0-9]').hasMatch(row[index - 1])) return false;
  final end = index + needle.length;
  if (end < row.length && RegExp(r'[A-Za-z0-9]').hasMatch(row[end])) {
    return false;
  }
  return true;
}

bool _isPercent(String row, int aliasEnd) {
  final rest = row.substring(aliasEnd).trimLeft();
  return rest.startsWith('%') || rest.startsWith('％');
}

_Span? _range(String row) {
  final match = RegExp(r'(\d+(?:\.\d+)?)\s*-\s*(\d+(?:\.\d+)?)').firstMatch(row);
  if (match == null) return null;
  final low = double.parse(match.group(1)!);
  final high = double.parse(match.group(2)!);
  if (high <= low) return null;
  if (low > 10000) return null;
  return _Span(match.start, match.end, low: low, high: high);
}

_Span? _unit(String row, LabAnalyte analyte, _Span? range) {
  final candidates = <(String, String)>[];
  for (final unit in analyte.units) {
    candidates.add((unit.label, unit.label));
    for (final alias in unit.aliases) {
      candidates.add((alias, unit.label));
    }
  }
  candidates.sort((a, b) => b.$1.length.compareTo(a.$1.length));
  final hay = normalizeUnit(row);
  // Search the original row as well as the normalized form. Positions are
  // only used to keep the result number out of the unit, so a normalized
  // hit still blocks the same digits in the original row via a second pass.
  for (final (alias, label) in candidates) {
    final needle = normalizeUnit(alias);
    if (needle.isEmpty) continue;
    final index = hay.indexOf(needle);
    if (index < 0) continue;
    final rawIndex = row.toLowerCase().indexOf(alias.toLowerCase());
    if (rawIndex >= 0) {
      return _Span(rawIndex, rawIndex + alias.length, label: label);
    }
    return _Span(0, 0, label: label);
  }
  if (range == null) return null;
  return null;
}

String _hideUnitTokens(String row) {
  final pattern = RegExp(
    r'[x×*]?\s*10\s*\^?\s*\d+\s*/\s*[A-Za-zμµu]+',
    caseSensitive: false,
  );
  return row.replaceAllMapped(pattern, (match) => ' ' * match.group(0)!.length);
}

double? _resultNumber(String row, int aliasEnd, List<_Span> blocked) {
  double? after;
  double? before;
  for (final match in RegExp(r'\d+(?:\.\d+)?').allMatches(row)) {
    if (blocked.any((span) => match.start < span.end && match.end > span.start)) {
      continue;
    }
    final value = double.parse(match.group(0)!);
    if (match.start >= aliasEnd) {
      after ??= value;
    } else {
      before = value;
    }
  }
  return after ?? before;
}

/// When the report printed no unit, pick the one whose usual range fits.
String inferLabUnit(LabAnalyte analyte, double value) {
  switch (analyte.code) {
    case 'HGB':
    case 'MCHC':
      return value < 30 ? 'g/dL' : 'g/L';
    case 'HCT':
      return value <= 1 ? 'L/L' : '%';
    case 'CREA':
      return value < 20 ? 'mg/dL' : 'µmol/L';
    case 'BUN':
      return value >= 15 ? 'mg/dL' : 'mmol/L';
    case 'GLU':
      return value > 30 ? 'mg/dL' : 'mmol/L';
    case 'TBIL':
      return value > 3 ? 'µmol/L' : 'mg/dL';
    case 'TP':
    case 'ALB':
    case 'GLOB':
      return value < 15 ? 'g/dL' : 'g/L';
    case 'PHOS':
      return value > 8 ? 'mg/dL' : 'mmol/L';
    case 'CA':
      return value > 5 ? 'mg/dL' : 'mmol/L';
    case 'CHOL':
      return value > 15 ? 'mg/dL' : 'mmol/L';
    case 'TT4':
      return value < 8 ? 'µg/dL' : 'nmol/L';
    default:
      return analyte.base.label;
  }
}
