import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/food/barcode_lookup.dart';
import 'package:maokangji/domain/search/pinyin.dart';
import 'package:maokangji/services/coat_recognizer.dart';
import 'package:maokangji/services/notification_service.dart';
import 'package:maokangji/state/app_controller.dart';

const _royal = '''
{"status":1,"product":{
  "brands":"Royal Canin",
  "product_name":"Royal Canin Neutered Satiety Balance veterinary care nutrition",
  "quantity":"12 kg",
  "ingredients_text":"Protéines de volailles déshydratées, maïs",
  "image_front_url":"https://images.openpetfoodfacts.org/images/products/318/255/079/9669/front_en.15.400.jpg",
  "nutriments":{
    "crude-protein":35,
    "crude-protein_100g":35,
    "proteins":35.0,
    "proteins_100g":3.5,
    "crude-fat_100g":10,
    "crude-fibre_100g":9.2,
    "crude-ash_100g":9.3
  }
}}
''';

void main() {
  test('pinyin initials match cat names and brands', () {
    expect(pinyinInitials('橘座'), 'jz');
    expect(pinyinInitials('奶油'), 'ny');
    expect(pinyinInitials('希尔斯'), 'xes');
    expect(matchesQuery('hj', '皇家 室内成猫'), isTrue);
    expect(matchesQuery('jz', '奶油'), isFalse);
    expect(matchesQuery('猫', '猫三联'), isTrue);
  });

  test(
    'a pet-food hit stops the chain and keeps the printed analysis',
    () async {
      final calls = <String>[];
      final record = await lookupBarcode(
        '3182550799669',
        fetch: (uri) async {
          calls.add(uri.toString());
          if (uri.host.contains('openpetfoodfacts')) {
            return const BarcodeResponse(200, _royal);
          }
          return const BarcodeResponse(404, '{"status":0}');
        },
      );
      expect(record.found, isTrue);
      expect(record.source, 'openpetfoodfacts');
      expect(record.brand, 'Royal Canin');
      expect(record.quantity, '12 kg');
      expect(record.ingredients, contains('Protéines'));
      expect(record.imageUrl, contains('318/255/079/9669'));
      expect(
        record.nutrients.firstWhere((item) => item.label == '粗蛋白').text,
        '35 %',
      );
      expect(calls, hasLength(1));
      expect(calls.single, contains('openpetfoodfacts'));
    },
  );

  test(
    'a 12-digit UPC is also tried as EAN-13 before the next source',
    () async {
      final codes = <String>[];
      final record = await lookupBarcode(
        '064992280178',
        fetch: (uri) async {
          codes.add(uri.pathSegments.last);
          if (uri.path.endsWith('0064992280178')) {
            return const BarcodeResponse(
              200,
              '{"status":1,"product":{"brands":"Orijen","product_name":"Original Cat","quantity":"17kg","ingredients_text":"Fresh chicken (20%)"}}',
            );
          }
          return const BarcodeResponse(404, '{"status":0}');
        },
      );
      expect(record.found, isTrue);
      expect(record.name, 'Original Cat');
      expect(codes, ['064992280178', '0064992280178']);
    },
  );

  test('a domestic miss asks every free source and then stops', () async {
    final hosts = <String>[];
    final record = await lookupBarcode(
      '6958862134620',
      fetch: (uri) async {
        hosts.add(uri.host);
        if (uri.host.contains('upcitemdb')) {
          return const BarcodeResponse(
            200,
            '{"code":"OK","total":0,"items":[]}',
          );
        }
        return const BarcodeResponse(404, '{"status":0}');
      },
    );
    expect(record.found, isFalse);
    expect(record.offline, isFalse);
    expect(hosts, [
      'world.openpetfoodfacts.org',
      'world.openfoodfacts.org',
      'world.openproductsfacts.org',
      'api.upcitemdb.com',
    ]);
  });

  test('barcode cache is still there after a restart', () async {
    final database = AppDatabase.memory();
    final repo = DriftCareRepository(database);
    final first = AppController(
      repo: repo,
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
    );
    await first.init();
    await first.saveBarcodeRecord(
      const BarcodeRecord(
        code: '3182550799669',
        found: true,
        brand: 'Royal Canin',
        name: 'Neutered Satiety Balance',
        quantity: '12 kg',
        ingredients: 'Protéines de volailles déshydratées',
        nutrients: [BarcodeNutrient(label: '粗蛋白', text: '35 %')],
        source: 'openpetfoodfacts',
      ),
    );
    await first.pushRecentSearch('jz');
    final second = AppController(
      repo: repo,
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
    );
    await second.init();
    final cached = second.cachedBarcode('03182550799669');
    expect(cached?.name, 'Neutered Satiety Balance');
    expect(cached?.nutrients.single.text, '35 %');
    expect(second.recentSearches, ['jz']);
    await database.close();
  });
}
