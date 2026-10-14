import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/domain/parsing/vaccine_sticker_parser.dart';

void main() {
  const parser = VaccineStickerParser();

  test('reads a Chinese combo sticker', () {
    final read = parser.parse('''
妙三多
猫三联疫苗
批号：A12B-3391
接种日期：2026年3月12日
''');
    expect(read.name, '猫三联');
    expect(read.knownName, isTrue);
    expect(read.batch, 'A12B-3391');
    expect(read.givenOn, DateTime(2026, 3, 12));
  });

  test('reads a rabies lot and an English date label', () {
    final read = parser.parse('''
Rabies Vaccine
Lot: RB2026X
Date: 2026-01-05
''');
    expect(read.name, '狂犬');
    expect(read.batch, 'RB2026X');
    expect(read.givenOn, DateTime(2026, 1, 5));
  });

  test('does not turn a phone number into a date or a lot', () {
    final read = parser.parse('客服 400-123-4567\n谢谢');
    expect(read.isEmpty, isTrue);
  });

  test('keeps an unknown vaccine line for the confirm chips', () {
    final read = parser.parse('猫用疫苗\n批号 LOT9981');
    expect(read.name, '猫用疫苗');
    expect(read.knownName, isFalse);
    expect(read.batch, 'LOT9981');
  });
}