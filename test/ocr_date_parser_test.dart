import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/domain/parsing/ocr_date_parser.dart';

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
}
