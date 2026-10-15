import 'pinyin_table.dart';

/// Lowercase pinyin initials plus any ASCII letters and digits already in
/// [text]. Characters without a reading are skipped.
String pinyinInitials(String text) {
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    if (rune >= 0x30 && rune <= 0x39) {
      buffer.writeCharCode(rune);
      continue;
    }
    if (rune >= 0x41 && rune <= 0x5a) {
      buffer.writeCharCode(rune + 0x20);
      continue;
    }
    if (rune >= 0x61 && rune <= 0x7a) {
      buffer.writeCharCode(rune);
      continue;
    }
    final index = rune - pinyinInitialBase;
    if (index < 0 || index >= pinyinInitialTable.length) continue;
    final letter = pinyinInitialTable.codeUnitAt(index);
    if (letter == 0x20) continue;
    buffer.writeCharCode(letter);
  }
  return buffer.toString();
}

/// Substring match, or a match against pinyin initials.
///
/// "jz" matches 橘座, "hj" matches 皇家. The original characters still match
/// on their own, so a Chinese query does not have to be spelled out.
bool matchesQuery(String query, String haystack) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty || haystack.trim().isEmpty) return false;
  if (haystack.toLowerCase().contains(needle)) return true;
  final letters = needle.replaceAll(RegExp('[^a-z0-9]'), '');
  if (letters.isEmpty) return false;
  return pinyinInitials(haystack).contains(letters);
}
