import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/domain/parsing/ocr_date_parser.dart';
import 'package:maokangji/domain/parsing/ocr_lines.dart';

void main() {
  const parser = OcrDateParser();

  test('reads labeled Chinese dates', () {
    final result = parser.parse('生产日期：2024年10月12日\n保质期至：2026年10月12日');
    expect(result.productionDate, DateTime(2024, 10, 12));
    expect(result.expiryDate, DateTime(2026, 10, 12));
    expect(result.expiryInferred, isFalse);
  });

  test('reads mixed separators and EXP', () {
    final result = parser.parse('生产日期:2024-10-12\nEXP 2026.10.12');
    expect(result.productionDate, DateTime(2024, 10, 12));
    expect(result.expiryDate, DateTime(2026, 10, 12));
  });

  test('reads compact digits and fullwidth characters', () {
    final result = parser.parse('MFG：２０２４１０１２\n有效期至:2026/10/12');
    expect(result.productionDate, DateTime(2024, 10, 12));
    expect(result.expiryDate, DateTime(2026, 10, 12));
  });

  test('infers expiry from a shelf-life of months', () {
    final result = parser.parse('生产日期：2025.01.01 保质期：18个月');
    expect(result.productionDate, DateTime(2025, 1, 1));
    expect(result.expiryDate, DateTime(2026, 7, 1));
    expect(result.shelfLifeText, '18个月');
    expect(result.expiryInferred, isTrue);
  });

  test('keeps an explicit expiry when a shelf life is also printed', () {
    final result = parser.parse('生产日期：2025-01-01\n保质期至：2026-02-01\n保质期：18个月');
    expect(result.expiryDate, DateTime(2026, 2, 1));
    expect(result.expiryInferred, isFalse);
    expect(result.shelfLifeText, '18个月');
  });

  test('does not invent a date from unlabeled numbers', () {
    final result = parser.parse('净含量 2000g  电话 4001234567');
    expect(result.hasDate, isFalse);
    expect(result.productionDate, isNull);
    expect(result.expiryDate, isNull);
  });

  test('shelf life alone cannot invent an expiry', () {
    final result = parser.parse('保质期 24个月');
    expect(result.expiryDate, isNull);
    expect(result.shelfLifeText, '24个月');
  });

  test('reads production slash shelf-life and English month names', () {
    final combined = parser.parse('生产日期：2025年1月1日/保质期18个月');
    expect(combined.productionDate, DateTime(2025, 1, 1));
    expect(combined.expiryDate, DateTime(2026, 7, 1));
    expect(combined.expiryInferred, isTrue);

    final english = parser.parse('MFG 2025-01-01 shelf life 18 months');
    expect(english.productionDate, DateTime(2025, 1, 1));
    expect(english.expiryDate, DateTime(2026, 7, 1));
  });

  test('reads 到期时间 and EXPIRY, including a date on the next line', () {
    expect(
      parser.parse('到期时间：2027年3月15日').expiryDate,
      DateTime(2027, 3, 15),
    );
    expect(
      parser.parse('到期时间\n2027-03-15').expiryDate,
      DateTime(2027, 3, 15),
    );
    expect(parser.parse('EXPIRY 15/03/2027').expiryDate, DateTime(2027, 3, 15));
    expect(parser.parse('EXP DATE 15.03.2027').expiryDate, DateTime(2027, 3, 15));
    final missed = parser.parse('净含量 2kg\n电话 4001234567');
    expect(missed.expiryDate, isNull);
    expect(missed.uncertain, isFalse);
  });

  test('a low-confidence expiry line is not turned into a date', () {
    final result = parser.parseLines(const [
      OcrLine('到期时间', confidence: 0.95),
      OcrLine('2027-03-15', confidence: 0.2),
    ]);
    expect(result.expiryDate, isNull);
    expect(result.productionDate, isNull);
    expect(result.uncertain, isTrue);
  });

  test('reads EXP, BBE and a month-only expiry as day first', () {
    expect(parser.parse('EXP 12/10/2026').expiryDate, DateTime(2026, 10, 12));
    expect(parser.parse('BBE: 12 OCT 2026').expiryDate, DateTime(2026, 10, 12));
    expect(
      parser.parse('BEST BEFORE 12.10.2026').expiryDate,
      DateTime(2026, 10, 12),
    );
    expect(parser.parse('保质期至 2026年10月').expiryDate, DateTime(2026, 10, 31));
  });
}
