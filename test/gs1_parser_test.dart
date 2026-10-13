import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/domain/parsing/gs1_parser.dart';

void main() {
  const parser = Gs1Parser();
  final reference = DateTime(2026, 10, 12);

  test('parentheses form reads production, expiry and batch', () {
    final result = parser.parse(
      '(11)251012(17)270412(10)LOT9',
      reference: reference,
    );
    expect(result.productionDate, DateTime(2025, 10, 12));
    expect(result.expiryDate, DateTime(2027, 4, 12));
    expect(result.batch, 'LOT9');
    expect(result.recognized, isTrue);
    expect(result.expiryIsBestBefore, isFalse);
  });

  test('GS separator and symbology prefix are accepted', () {
    final result = parser.parse(
      ']d211251012\u001d17270412\u001d10BATCH',
      reference: reference,
    );
    expect(result.productionDate, DateTime(2025, 10, 12));
    expect(result.expiryDate, DateTime(2027, 4, 12));
    expect(result.batch, 'BATCH');
  });

  test('concatenated fixed-length dates do not need a separator', () {
    final result = parser.parse('1125101217270412', reference: reference);
    expect(result.productionDate, DateTime(2025, 10, 12));
    expect(result.expiryDate, DateTime(2027, 4, 12));
    expect(result.batch, isNull);
  });

  test('day 00 means the last day of the month', () {
    final result = parser.parse('(17)270400', reference: reference);
    expect(result.expiryDate, DateTime(2027, 4, 30));
  });

  test('AI 15 is best-before, not an expiry', () {
    final result = parser.parse(
      '(15)261130(01)06971000000014',
      reference: reference,
    );
    expect(result.bestBeforeDate, DateTime(2026, 11, 30));
    expect(result.expiryDate, isNull);
    expect(result.suggestedExpiry, DateTime(2026, 11, 30));
    expect(result.expiryIsBestBefore, isTrue);
    expect(result.gtin, '06971000000014');
  });

  test('invalid month and a plain EAN are not dates', () {
    expect(
      parser.parse('(11)251322', reference: reference).productionDate,
      isNull,
    );
    final ean = parser.parse('6971000000014', reference: reference);
    expect(ean.recognized, isFalse);
    expect(ean.expiryDate, isNull);
  });
}
