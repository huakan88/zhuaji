/// What was read off a printed vaccine sticker. The user confirms it
/// before anything is saved.
class VaccineStickerRead {
  const VaccineStickerRead({
    this.name,
    this.knownName = false,
    this.batch,
    this.givenOn,
  });

  /// `猫三联`, `狂犬`, or a short line that contained 疫苗.
  final String? name;

  /// True when [name] is one of the two doses this app already logs.
  final bool knownName;
  final String? batch;
  final DateTime? givenOn;

  bool get isEmpty => name == null && batch == null && givenOn == null;
}

class VaccineStickerParser {
  const VaccineStickerParser();

  static const _aliases = <(String, String)>[
    ('猫三联', '猫三联'),
    ('妙三多', '猫三联'),
    ('felocell', '猫三联'),
    ('purevax', '猫三联'),
    ('nobivac', '猫三联'),
    ('卫佳', '猫三联'),
    ('三联', '猫三联'),
    ('狂犬病', '狂犬'),
    ('rabies', '狂犬'),
    ('defensor', '狂犬'),
    ('狂犬', '狂犬'),
  ];

  static final _batch = RegExp(
    r'(?:批号|批次|LOT|Lot|lot|Batch|BATCH)\s*[:：#]?\s*([A-Za-z0-9][A-Za-z0-9\-]{3,24})',
  );
  static final _labeledDate = RegExp(
    r'(?:接种日期|接种日|注射日期|日期|Date|DATE)\s*[:：]?\s*'
    r'(\d{4})\s*[年\-/.]\s*(\d{1,2})\s*[月\-/.]\s*(\d{1,2})',
  );
  static final _anyDate = RegExp(
    r'(\d{4})\s*[年\-/.]\s*(\d{1,2})\s*[月\-/.]\s*(\d{1,2})',
  );

  VaccineStickerRead parse(String raw) {
    final text = _foldDigits(raw);
    final name = _name(text);
    return VaccineStickerRead(
      name: name?.$1,
      knownName: name?.$2 ?? false,
      batch: _batchOf(text),
      givenOn: _date(text),
    );
  }

  (String, bool)? _name(String text) {
    final folded = text.toLowerCase();
    final hits = <(int, int, String)>[];
    for (final alias in _aliases) {
      final index = folded.indexOf(alias.$1.toLowerCase());
      if (index >= 0) hits.add((index, alias.$1.length, alias.$2));
    }
    if (hits.isNotEmpty) {
      hits.sort((a, b) {
        final byIndex = a.$1.compareTo(b.$1);
        if (byIndex != 0) return byIndex;
        return b.$2.compareTo(a.$2);
      });
      return (hits.first.$3, true);
    }
    for (final line in text.split(RegExp(r'[\r\n]+'))) {
      final trimmed = line.trim();
      if (trimmed.contains('疫苗') && trimmed.length <= 16 && trimmed.isNotEmpty) {
        return (trimmed, false);
      }
    }
    return null;
  }

  String? _batchOf(String text) {
    final match = _batch.firstMatch(text);
    if (match == null) return null;
    final token = match.group(1)!;
    if (RegExp(r'^\d{8}$').hasMatch(token)) return null;
    if (RegExp(r'^\d{4}$').hasMatch(token)) return null;
    return token;
  }

  DateTime? _date(String text) {
    final labeled = _labeledDate.firstMatch(text);
    if (labeled != null) {
      return _valid(
        int.parse(labeled.group(1)!),
        int.parse(labeled.group(2)!),
        int.parse(labeled.group(3)!),
      );
    }
    final any = _anyDate.firstMatch(text);
    if (any == null) return null;
    return _valid(
      int.parse(any.group(1)!),
      int.parse(any.group(2)!),
      int.parse(any.group(3)!),
    );
  }

  DateTime? _valid(int year, int month, int day) {
    if (year < 2000 || year > 2100 || month < 1 || month > 12) return null;
    final last = DateTime(year, month + 1, 0).day;
    if (day < 1 || day > last) return null;
    return DateTime(year, month, day);
  }

  /// Digits and ASCII punctuation only. The shared half-width helper also
  /// rewrites 一, which would break 猫三联.
  String _foldDigits(String raw) {
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
    return buffer.toString();
  }
}
