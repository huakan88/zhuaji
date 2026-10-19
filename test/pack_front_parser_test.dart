import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/domain/food_options.dart';
import 'package:maokangji/domain/models.dart';
import 'package:maokangji/domain/parsing/ocr_lines.dart';
import 'package:maokangji/domain/parsing/pack_front_parser.dart';

void main() {
  const parser = PackFrontParser();

  test('a known front of pack fills brand, name, flavor, form and size', () {
    final read = parser.parse('''
ROYAL CANIN
皇家
室内成猫全价猫粮
鸡肉味
净含量：2kg
''');
    expect(read.brand, '皇家 Royal Canin');
    expect(read.name, '室内成猫全价猫粮');
    expect(read.flavor, '鸡肉');
    expect(read.form, FoodForm.dry);
    expect(read.spec, '2kg');
  });

  test('主食罐 is not read as a pouch, and an unknown brand is still guessed', () {
    final can = parser.parse('网易严选\n三文鱼主食罐\n85g');
    expect(can.brand, '网易严选');
    expect(can.name, '三文鱼主食罐');
    expect(can.form, FoodForm.can);
    expect(can.flavor, '三文鱼');
    expect(can.spec, '85g');

    final local = parser.parse('山野\n冻干双拼成猫粮\n1.5 kg');
    expect(local.brand, '山野');
    expect(local.name, '冻干双拼成猫粮');
    expect(local.form, FoodForm.freezeDried);
    expect(local.spec, '1.5kg');
  });

  test('labeled fields stay in their own slots, including 到期时间', () {
    final read = parser.parse('''
品牌：麦富迪
产品名称：三文鱼双拼全价猫粮
净含量：2kg
配料：鸡肉、三文鱼、鱼油
生产日期：2026年3月15日
到期时间：2027年3月15日
''');
    expect(read.brand, '麦富迪 Myfoodie');
    expect(read.name, '三文鱼双拼全价猫粮');
    expect(read.spec, '2kg');
    expect(read.ingredients, '鸡肉、三文鱼、鱼油');
    expect(read.productionDate, DateTime(2026, 3, 15));
    expect(read.expiryDate, DateTime(2027, 3, 15));
    expect(read.name, isNot(contains('到期')));
    expect(read.expiryUncertain, isFalse);
  });

  test('an unknown brand and EXP on the next line are not dumped into the name', () {
    final read = parser.parse('''
品牌：伯纳天纯
产品名称：全价成猫粮
EXP
15/03/2027
''');
    expect(read.brand, '伯纳天纯');
    expect(read.name, '全价成猫粮');
    expect(read.expiryDate, DateTime(2027, 3, 15));
    expect(read.expiryUncertain, isFalse);
  });

  test('a low-confidence expiry stays empty', () {
    final read = parser.parse(
      '伯纳天纯\n全价成猫粮',
      lines: const [
        OcrLine('品牌：伯纳天纯', confidence: 0.9),
        OcrLine('产品名称：全价成猫粮', confidence: 0.9),
        OcrLine('到期时间', confidence: 0.9),
        OcrLine('2028年1月1日', confidence: 0.1),
      ],
    );
    expect(read.brand, '伯纳天纯');
    expect(read.name, '全价成猫粮');
    expect(read.expiryDate, isNull);
    expect(read.expiryUncertain, isTrue);
  });

  test('brand and name on one line still split', () {
    final read = parser.parse('皇家室内成猫粮\n2千克');
    expect(read.brand, '皇家 Royal Canin');
    expect(read.name, '室内成猫粮');
    expect(read.spec, '2kg');
  });

  test('catalog search finds a custom food by flavor and by 自定义', () {
    const custom = FoodProduct(
      id: 9,
      brand: '山野',
      name: '冻干双拼',
      spec: '1.5kg',
      foodForm: FoodForm.freezeDried,
      storageMethod: '',
      afterOpenDays: 30,
      isSample: false,
      flavor: '鸡肉',
      isCustom: true,
    );
    const sample = FoodProduct(
      id: 1,
      brand: '皇家 Royal Canin',
      name: '室内成猫干粮',
      spec: '',
      foodForm: FoodForm.dry,
      storageMethod: '',
      afterOpenDays: 30,
      isSample: true,
    );
    expect(filterFoods(const [sample, custom], '山野').single.id, 9);
    expect(filterFoods(const [sample, custom], '鸡肉').single.isCustom, isTrue);
    expect(filterFoods(const [sample, custom], '自定义').single.id, 9);
    expect(filterFoods(const [sample, custom], '皇家').single.isSample, isTrue);
    expect(filterFoods(const [sample, custom], '').first.isCustom, isTrue);
  });
}
