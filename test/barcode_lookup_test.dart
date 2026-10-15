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
        fetch: (call) async {
          calls.add(call.uri.toString());
          if (call.uri.host.contains('openpetfoodfacts')) {
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
        fetch: (call) async {
          codes.add(call.uri.pathSegments.last);
          if (call.uri.path.endsWith('0064992280178')) {
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
      fetch: (call) async {
        hosts.add(call.uri.host);
        if (call.uri.host.contains('upcitemdb')) {
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
    expect(record.incomplete, isFalse);
    expect(hosts, [
      'world.openpetfoodfacts.org',
      'world.openfoodfacts.org',
      'world.openproductsfacts.org',
      'myproduct.guru',
      'api.upcitemdb.com',
    ]);
    expect(hosts, isNot(contains('v.juhe.cn')));
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

  test(
    'ProductGuru names the product when the pet-food site is down',
    () async {
      final hosts = <String>[];
      final record = await lookupBarcode(
        '3182550799669',
        fetch: (call) async {
          hosts.add(call.uri.host);
          if (call.uri.host == 'myproduct.guru') {
            return const BarcodeResponse(
              200,
              '{"ean":"3182550799669","name":"Royal Canin Neutered Satiety Balance","brand":"Royal Canin","quantity":"12 kg","web_url":"https://myproduct.guru/p/3182550799669","source":"ProductGuru"}',
            );
          }
          if (call.uri.host.contains('openpetfoodfacts')) {
            return const BarcodeResponse(502, '');
          }
          return const BarcodeResponse(404, '{"status":0}');
        },
      );
      expect(record.found, isTrue);
      expect(record.source, 'productguru');
      expect(record.brand, 'Royal Canin');
      expect(record.quantity, '12 kg');
      expect(record.ingredients, isEmpty);
      expect(record.sourceUrl, 'https://myproduct.guru/p/3182550799669');
      expect(hosts, contains('myproduct.guru'));
    },
  );

  test('a domestic outage is not cached as a confirmed miss', () async {
    final database = AppDatabase.memory();
    final repo = DriftCareRepository(database);
    final controller = AppController(
      repo: repo,
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
    );
    await controller.init();
    controller.barcodeFetch = (call) async {
      if (call.uri.host.contains('openpetfoodfacts')) {
        return const BarcodeResponse(502, '');
      }
      if (call.uri.host.contains('upcitemdb')) {
        return const BarcodeResponse(200, '{"code":"OK","total":0,"items":[]}');
      }
      return const BarcodeResponse(404, '{"status":0}');
    };
    final record = await controller.resolveBarcode('6958862134620');
    expect(record.found, isFalse);
    expect(record.incomplete, isTrue);
    expect(controller.cachedBarcode('6958862134620'), isNull);
    await database.close();
  });

  test('a juhe key reads a domestic product and stops the chain', () async {
    final hosts = <String>[];
    final record = await lookupBarcode(
      '6958862134620',
      keys: const BarcodeKeys(juhe: 'test-key'),
      fetch: (call) async {
        hosts.add(call.uri.host);
        expect(call.timeout.inSeconds, lessThanOrEqualTo(4));
        if (call.uri.host == 'v.juhe.cn') {
          expect(call.uri.queryParameters['key'], 'test-key');
          return const BarcodeResponse(
            200,
            '{"resultcode":"200","reason":"success","error_code":0,"result":{"goodsName":"三文鱼双拼全价全期猫粮","trademark":"麦富迪","spec":"2千克","img":"https://example.com/myfoodie.jpg"}}',
          );
        }
        return const BarcodeResponse(404, '');
      },
    );
    expect(record.found, isTrue);
    expect(record.source, 'juhe');
    expect(record.brand, '麦富迪');
    expect(record.name, '三文鱼双拼全价全期猫粮');
    expect(record.quantity, '2千克');
    expect(record.imageUrl, 'https://example.com/myfoodie.jpg');
    expect(hosts, ['v.juhe.cn']);
  });

  test('a bad juhe key is skipped and the free sources still run', () async {
    final hosts = <String>[];
    final record = await lookupBarcode(
      '6958862134620',
      keys: const BarcodeKeys(juhe: 'bad'),
      fetch: (call) async {
        hosts.add(call.uri.host);
        if (call.uri.host == 'v.juhe.cn') {
          return const BarcodeResponse(
            200,
            '{"resultcode":"101","reason":"错误的请求KEY","result":null,"error_code":10001}',
          );
        }
        if (call.uri.host == 'api.topthink.com') {
          return const BarcodeResponse(
            200,
            '{"code":0,"message":"查询成功","data":{"goodsName":"白身吞拿鱼","trademark":"wanpy","spec":"85克","img":""}}',
          );
        }
        return const BarcodeResponse(404, '{"status":0}');
      },
    );
    expect(hosts.first, 'v.juhe.cn');
    expect(record.found, isFalse);
    expect(hosts, contains('myproduct.guru'));
  });

  test(
    'topthink, showapi, go-upc and ean-search parsers keep a name',
    () async {
      final topthink = await lookupBarcode(
        '6945496203099',
        keys: const BarcodeKeys(topthink: 'token'),
        fetch: (call) async {
          expect(call.headers['Authorization'], 'Bearer token');
          return const BarcodeResponse(
            200,
            '{"code":0,"message":"查询成功","data":{"goodsName":"白身吞拿鱼配方","trademark":"wanpy","spec":"85克","img":"https://example.com/wanpy.jpg","ret_code":"0","flag":true}}',
          );
        },
      );
      expect(topthink.source, 'topthink');
      expect(topthink.brand, 'wanpy');
      expect(topthink.quantity, '85克');
      expect(topthink.imageUrl, 'https://example.com/wanpy.jpg');

      final showapi = await lookupBarcode(
        '6917878081946',
        keys: const BarcodeKeys(aliyunAppCode: 'appcode'),
        fetch: (call) async {
          expect(call.headers['Authorization'], 'APPCODE appcode');
          return const BarcodeResponse(
            200,
            '{"showapi_res_code":0,"showapi_res_body":{"flag":"true","ret_code":"0","goodsName":"鸡肉配方成年期全价猫粮","trademark":"冠能","spec":"2.5千克","img":""}}',
          );
        },
      );
      expect(showapi.brand, '冠能');
      expect(showapi.quantity, '2.5千克');
      expect(showapi.imageUrl, isNull);

      final goupc = await lookupBarcode(
        '3182550799669',
        keys: const BarcodeKeys(goUpc: 'upc-key'),
        fetch: (call) async {
          if (call.uri.host != 'go-upc.com') {
            return const BarcodeResponse(404, '');
          }
          expect(call.headers['Authorization'], 'Bearer upc-key');
          return const BarcodeResponse(
            200,
            '{"product":{"name":"Neutered Satiety Balance","brand":"Royal Canin","imageUrl":"https://example.com/royal.jpg","ingredients":{"text":"Poultry meal"}}}',
          );
        },
      );
      expect(goupc.source, 'goupc');
      expect(goupc.ingredients, 'Poultry meal');
      expect(goupc.imageUrl, contains('royal.jpg'));

      final ean = await lookupBarcode(
        '6914973700871',
        keys: const BarcodeKeys(eanSearch: 'ean-token'),
        fetch: (call) async {
          if (!call.uri.host.contains('ean-search')) {
            return const BarcodeResponse(404, '');
          }
          expect(call.uri.queryParameters['token'], 'ean-token');
          return const BarcodeResponse(
            200,
            '[{"ean":"6914973700871","name":"伟嘉全价成猫猫粮海洋鱼口味 1.3kg"}]',
          );
        },
      );
      expect(ean.source, 'eansearch');
      expect(ean.name, contains('伟嘉'));
      expect(ean.quantity, '1.3kg');
    },
  );
}
