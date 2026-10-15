import 'dart:convert';

import '../models.dart';

/// One HTTP reply from a public product database.
class BarcodeResponse {
  const BarcodeResponse(this.status, this.body);

  final int status;
  final String body;
}

/// One outbound lookup. [timeout] is the budget for this attempt.
class BarcodeCall {
  const BarcodeCall(
    this.uri, {
    this.headers = const {},
    this.timeout = const Duration(seconds: 4),
  });

  final Uri uri;
  final Map<String, String> headers;
  final Duration timeout;
}

typedef BarcodeFetch = Future<BarcodeResponse> Function(BarcodeCall call);

/// Keys for documented barcode APIs. Empty means that source is not called.
class BarcodeKeys {
  const BarcodeKeys({
    this.juhe = '',
    this.aliyunAppCode = '',
    this.topthink = '',
    this.goUpc = '',
    this.eanSearch = '',
  });

  /// 聚合数据 https://v.juhe.cn/barcode/query
  final String juhe;

  /// 阿里云市场商品条码，`Authorization: APPCODE`.
  final String aliyunAppCode;

  /// 顶想云 https://api.topthink.com/barcode/query ，Bearer 访问令牌。
  final String topthink;

  /// Go-UPC https://go-upc.com/api/v1/code/
  final String goUpc;

  /// EAN-Search https://api.ean-search.org/api
  final String eanSearch;

  bool get hasDomestic =>
      juhe.isNotEmpty || aliyunAppCode.isNotEmpty || topthink.isNotEmpty;
}

class BarcodeNutrient {
  const BarcodeNutrient({required this.label, required this.text});

  final String label;
  final String text;

  Map<String, String> toJson() => {'label': label, 'text': text};

  factory BarcodeNutrient.fromJson(Map<dynamic, dynamic> json) {
    return BarcodeNutrient(
      label: '${json['label'] ?? ''}',
      text: '${json['text'] ?? ''}',
    );
  }
}

/// A product resolved from a public barcode database, or a recorded miss.
class BarcodeRecord {
  const BarcodeRecord({
    required this.code,
    required this.found,
    required this.brand,
    required this.name,
    required this.quantity,
    required this.ingredients,
    required this.nutrients,
    required this.source,
    this.imageUrl,
    this.sourceUrl,
    this.kcalPer100g,
    this.offline = false,
    this.incomplete = false,
  });

  final String code;
  final bool found;
  final bool offline;

  /// Some databases answered, and at least one did not respond.
  /// A miss like this is not cached, so the next scan can try again.
  final bool incomplete;
  final String brand;
  final String name;
  final String quantity;
  final String ingredients;
  final List<BarcodeNutrient> nutrients;
  final String? imageUrl;
  final String? sourceUrl;

  /// Which database named the product. Empty when nothing matched.
  final String source;
  final double? kcalPer100g;

  String get sourceLabel => switch (source) {
    'openpetfoodfacts' => 'Open Pet Food Facts',
    'openfoodfacts' => 'Open Food Facts',
    'openproductsfacts' => 'Open Products Facts',
    'upcitemdb' => 'UPCitemdb',
    'productguru' => 'ProductGuru',
    'juhe' => '聚合数据',
    'aliyun' => '阿里云市场条码',
    'topthink' => '顶想云',
    'goupc' => 'Go-UPC',
    'eansearch' => 'EAN-Search',
    _ => '',
  };

  factory BarcodeRecord.miss(String code) {
    return BarcodeRecord(
      code: code.trim(),
      found: false,
      brand: '',
      name: '',
      quantity: '',
      ingredients: '',
      nutrients: const [],
      source: '',
    );
  }

  factory BarcodeRecord.offline(String code) {
    return BarcodeRecord(
      code: code.trim(),
      found: false,
      offline: true,
      brand: '',
      name: '',
      quantity: '',
      ingredients: '',
      nutrients: const [],
      source: '',
    );
  }

  Map<String, Object?> toJson() => {
    'code': code,
    'found': found,
    'offline': offline,
    'brand': brand,
    'name': name,
    'quantity': quantity,
    'ingredients': ingredients,
    'nutrients': [for (final item in nutrients) item.toJson()],
    'imageUrl': imageUrl,
    'sourceUrl': sourceUrl,
    'source': source,
    'kcalPer100g': kcalPer100g,
    'incomplete': incomplete,
  };

  factory BarcodeRecord.fromJson(Map<dynamic, dynamic> json) {
    final rawNutrients = json['nutrients'];
    final kcal = json['kcalPer100g'];
    return BarcodeRecord(
      code: '${json['code'] ?? ''}',
      found: json['found'] == true,
      offline: json['offline'] == true,
      brand: '${json['brand'] ?? ''}',
      name: '${json['name'] ?? ''}',
      quantity: '${json['quantity'] ?? ''}',
      ingredients: '${json['ingredients'] ?? ''}',
      nutrients: [
        if (rawNutrients is List)
          for (final item in rawNutrients)
            if (item is Map) BarcodeNutrient.fromJson(item),
      ],
      imageUrl: json['imageUrl'] is String ? json['imageUrl'] as String : null,
      sourceUrl: json['sourceUrl'] is String
          ? json['sourceUrl'] as String
          : null,
      source: '${json['source'] ?? ''}',
      kcalPer100g: kcal is num ? kcal.toDouble() : null,
      incomplete: json['incomplete'] == true,
    );
  }
}

/// EAN-8, UPC-A, EAN-13 and GTIN-14. GS1 element strings stay on the date path.
bool isRetailBarcode(String raw) {
  return RegExp(r'^\d{8}$|^\d{12}$|^\d{13}$|^\d{14}$').hasMatch(raw.trim());
}

/// The printed code, plus the 13-digit form of a 12-digit UPC (and the reverse).
List<String> barcodeCandidates(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? const [] : [trimmed];
  }
  final out = <String>[digits];
  void add(String value) {
    if (value.isNotEmpty && !out.contains(value)) out.add(value);
  }

  if (digits.length == 12) add('0$digits');
  if (digits.length == 13 && digits.startsWith('0')) add(digits.substring(1));
  if (digits.length == 14) {
    add(digits.substring(1));
    if (digits.startsWith('00')) add(digits.substring(2));
  }
  return out;
}

const _openFacts = <(String, String)>[
  ('openpetfoodfacts', 'https://world.openpetfoodfacts.org/api/v2/product/'),
  ('openfoodfacts', 'https://world.openfoodfacts.org/api/v2/product/'),
  ('openproductsfacts', 'https://world.openproductsfacts.org/api/v2/product/'),
];

const lookupBudget = Duration(seconds: 12);
const lookupAttempt = Duration(seconds: 4);

class SourceReply {
  const SourceReply.hit(this.record) : miss = false;
  const SourceReply.miss() : record = null, miss = true;
  const SourceReply.skip() : record = null, miss = false;

  final BarcodeRecord? record;
  final bool miss;
}

/// Looks up [code] until one database names it.
///
/// 69-prefix codes try the configured domestic APIs first. Every code then
/// walks Open Pet Food Facts, Open Food Facts, Open Products Facts,
/// ProductGuru, and the UPCitemdb trial. Go-UPC and EAN-Search run last,
/// and only when a key is set. Each attempt has [lookupAttempt]; the whole
/// walk stops at [lookupBudget].
///
/// A named hit is returned immediately. If every source that answered said
/// the code is unknown, the result is a miss. If any source failed to
/// answer, [BarcodeRecord.incomplete] is set and the caller should not cache
/// it. If nobody answered, the result is [BarcodeRecord.offline].
///
/// 中国物品编码中心的网站后台没有公开文档，这里不调用。
Future<BarcodeRecord> lookupBarcode(
  String code, {
  required BarcodeFetch fetch,
  BarcodeKeys keys = const BarcodeKeys(),
}) async {
  final requested = code.trim();
  final candidates = barcodeCandidates(requested);
  final started = DateTime.now();
  var definitive = false;
  var degraded = false;

  Future<BarcodeRecord?> ask(
    BarcodeCall call,
    SourceReply Function(int status, String body) interpret,
  ) async {
    final elapsed = DateTime.now().difference(started);
    if (elapsed >= lookupBudget) return null;
    var timeout = call.timeout;
    final left = lookupBudget - elapsed;
    if (left < timeout) timeout = left;
    if (timeout < const Duration(milliseconds: 250)) return null;
    try {
      final response = await fetch(
        BarcodeCall(call.uri, headers: call.headers, timeout: timeout),
      ).timeout(timeout, onTimeout: () => const BarcodeResponse(0, ''));
      if (response.status <= 0 || response.status >= 500) {
        degraded = true;
        return null;
      }
      final reply = interpret(response.status, response.body);
      if (reply.record != null) return reply.record;
      if (reply.miss) definitive = true;
      return null;
    } catch (_) {
      degraded = true;
      return null;
    }
  }

  Future<BarcodeRecord?> walk(
    List<Future<BarcodeRecord?> Function()> steps,
  ) async {
    for (final step in steps) {
      final hit = await step();
      if (hit != null) return hit;
    }
    return null;
  }

  final domestic = <Future<BarcodeRecord?> Function()>[
    if (keys.juhe.isNotEmpty)
      () => _overCandidates(candidates, (candidate) {
        return ask(
          BarcodeCall(
            Uri.https('v.juhe.cn', '/barcode/query', {
              'key': keys.juhe,
              'barcode': candidate,
            }),
          ),
          (status, body) => _juheReply(status, body, requested),
        );
      }),
    if (keys.aliyunAppCode.isNotEmpty)
      () => _overCandidates(candidates, (candidate) {
        return ask(
          BarcodeCall(
            Uri.https('ali-barcode.showapi.com', '/barcode', {
              'code': candidate,
            }),
            headers: {'Authorization': 'APPCODE ${keys.aliyunAppCode}'},
          ),
          (status, body) => _showapiReply(status, body, requested),
        );
      }),
    if (keys.topthink.isNotEmpty)
      () => _overCandidates(candidates, (candidate) {
        return ask(
          BarcodeCall(
            Uri.https('api.topthink.com', '/barcode/query', {
              'code': candidate,
            }),
            headers: {'Authorization': 'Bearer ${keys.topthink}'},
          ),
          (status, body) => _topthinkReply(status, body, requested),
        );
      }),
  ];
  final open = <Future<BarcodeRecord?> Function()>[
    () async {
      for (final source in _openFacts) {
        final hit = await _overCandidates(candidates, (candidate) {
          return ask(
            BarcodeCall(Uri.parse('${source.$2}$candidate')),
            (status, body) => _namedReply(
              status,
              body,
              (raw) => _openFactsReply(raw, source.$1, requested),
            ),
          );
        });
        if (hit != null) return hit;
      }
      return null;
    },
    () => _overCandidates(candidates, (candidate) {
      return ask(
        BarcodeCall(Uri.parse('https://myproduct.guru/lookup/$candidate.json')),
        (status, body) => _namedReply(
          status,
          body,
          (raw) => parseProductGuru(raw, requested),
        ),
      );
    }),
    () => _overCandidates(candidates, (candidate) {
      return ask(
        BarcodeCall(
          Uri.https('api.upcitemdb.com', '/prod/trial/lookup', {
            'upc': candidate,
          }),
        ),
        (status, body) =>
            _namedReply(status, body, (raw) => _upcReply(raw, requested)),
      );
    }),
  ];
  final keyed = <Future<BarcodeRecord?> Function()>[
    if (keys.goUpc.isNotEmpty)
      () => _overCandidates(candidates, (candidate) {
        return ask(
          BarcodeCall(
            Uri.parse('https://go-upc.com/api/v1/code/$candidate'),
            headers: {'Authorization': 'Bearer ${keys.goUpc}'},
          ),
          (status, body) =>
              _namedReply(status, body, (raw) => parseGoUpc(raw, requested)),
        );
      }),
    if (keys.eanSearch.isNotEmpty)
      () => _overCandidates(candidates, (candidate) {
        return ask(
          BarcodeCall(
            Uri.https('api.ean-search.org', '/api', {
              'token': keys.eanSearch,
              'op': 'barcode-lookup',
              'format': 'json',
              'ean': candidate,
            }),
          ),
          (status, body) => _namedReply(
            status,
            body,
            (raw) => parseEanSearch(raw, requested),
          ),
        );
      }),
  ];

  final preferDomestic = _isDomesticGtin(requested);
  final ordered = <Future<BarcodeRecord?> Function()>[
    if (preferDomestic) ...domestic,
    ...open,
    if (!preferDomestic) ...domestic,
    ...keyed,
  ];
  final hit = await walk(ordered);
  if (hit != null) return hit;
  if (!definitive) return BarcodeRecord.offline(requested);
  if (degraded) {
    return BarcodeRecord(
      code: requested,
      found: false,
      offline: false,
      incomplete: true,
      brand: '',
      name: '',
      quantity: '',
      ingredients: '',
      nutrients: const [],
      source: '',
    );
  }
  return BarcodeRecord.miss(requested);
}

bool _isDomesticGtin(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  return digits.startsWith('69') ||
      (digits.length == 14 && digits.startsWith('069'));
}

Future<BarcodeRecord?> _overCandidates(
  List<String> candidates,
  Future<BarcodeRecord?> Function(String candidate) step,
) async {
  for (final candidate in candidates) {
    final hit = await step(candidate);
    if (hit != null) return hit;
  }
  return null;
}

SourceReply _namedReply(
  int status,
  String body,
  SourceReply Function(String body) parse,
) {
  if (status == 401 || status == 403) return const SourceReply.skip();
  if (status != 200 || body.isEmpty) return const SourceReply.miss();
  return parse(body);
}

SourceReply _openFactsReply(String body, String source, String requested) {
  final record = parseOpenFacts(body, source, requested);
  if (record == null) return const SourceReply.miss();
  return SourceReply.hit(record);
}

SourceReply _upcReply(String body, String requested) {
  final record = parseUpcItemDb(body, requested);
  if (record == null) return const SourceReply.miss();
  return SourceReply.hit(record);
}

BarcodeRecord? parseOpenFacts(String body, String source, String requested) {
  final decoded = _jsonMap(body);
  if (decoded == null) return null;
  final status = decoded['status'];
  if (status != 1 && status != '1') return null;
  final product = decoded['product'];
  if (product is! Map) return null;
  final brand = _firstText(product, const ['brands', 'brand']);
  final name = _firstText(product, const [
    'product_name_zh',
    'product_name',
    'product_name_en',
    'product_name_fr',
  ]);
  if (brand.isEmpty && name.isEmpty) return null;
  final quantity = _firstText(product, const ['quantity', 'product_quantity']);
  final ingredients = _collapse(
    _firstText(product, const [
      'ingredients_text_zh',
      'ingredients_text',
      'ingredients_text_en',
      'ingredients_text_fr',
    ]),
  );
  final nutriments = product['nutriments'];
  final nutrients = nutriments is Map
      ? readNutrients(nutriments)
      : const <BarcodeNutrient>[];
  final image = _firstText(product, const [
    'image_front_url',
    'image_url',
    'image_front_small_url',
  ]);
  final kcal = nutriments is Map ? readKcal(nutriments) : null;
  return BarcodeRecord(
    code: requested,
    found: true,
    brand: brand,
    name: name.isEmpty ? brand : name,
    quantity: quantity,
    ingredients: ingredients,
    nutrients: nutrients,
    imageUrl: image.isEmpty ? null : image,
    source: source,
    kcalPer100g: kcal,
  );
}

BarcodeRecord? parseUpcItemDb(String body, String requested) {
  final decoded = _jsonMap(body);
  if (decoded == null) return null;
  final total = decoded['total'];
  if (total is num && total <= 0) return null;
  final items = decoded['items'];
  if (items is! List || items.isEmpty || items.first is! Map) return null;
  final item = items.first as Map;
  final brand = _firstText(item, const ['brand']);
  final name = _firstText(item, const ['title', 'name']);
  if (brand.isEmpty && name.isEmpty) return null;
  final images = item['images'];
  String? image;
  if (images is List && images.isNotEmpty && images.first is String) {
    final url = (images.first as String).trim();
    if (url.startsWith('https://') || url.startsWith('http://')) image = url;
  }
  final description = _collapse(_firstText(item, const ['description']));
  return BarcodeRecord(
    code: requested,
    found: true,
    brand: brand,
    name: name.isEmpty ? brand : name,
    quantity: _quantityHint('$name $description'),
    ingredients: '',
    nutrients: const [],
    imageUrl: image,
    source: 'upcitemdb',
  );
}

/// Guaranteed-analysis style figures. Open Pet Food Facts sometimes stores
/// `proteins_100g` as a tenth of `proteins`; when the two disagree by about
/// 10×, the unsuffixed figure is the one printed on the bag.
List<BarcodeNutrient> readNutrients(Map<dynamic, dynamic> nutriments) {
  const lines = <(String, String, String)>[
    ('energy-kcal', '能量', 'kcal/100g'),
    ('crude-protein', '粗蛋白', '%'),
    ('crude-fat', '粗脂肪', '%'),
    ('crude-fibre', '粗纤维', '%'),
    ('crude-fiber', '粗纤维', '%'),
    ('crude-ash', '粗灰分', '%'),
    ('moisture', '水分', '%'),
    ('calcium', '钙', '%'),
    ('phosphorus', '磷', '%'),
    ('taurine', '牛磺酸', '%'),
  ];
  final out = <BarcodeNutrient>[];
  final seen = <String>{};
  for (final line in lines) {
    if (seen.contains(line.$2)) continue;
    final value = readNutrient(nutriments, line.$1);
    if (value == null || value == 0) continue;
    seen.add(line.$2);
    out.add(
      BarcodeNutrient(
        label: line.$2,
        text: '${formatLookupNumber(value)} ${line.$3}',
      ),
    );
  }
  return out;
}

double? readKcal(Map<dynamic, dynamic> nutriments) {
  final value = readNutrient(nutriments, 'energy-kcal');
  if (value == null || value < 40 || value > 800) return null;
  return value;
}

double? readNutrient(Map<dynamic, dynamic> nutriments, String base) {
  final hundred = _asDouble(nutriments['${base}_100g']);
  final plain = _asDouble(nutriments[base]);
  if (hundred != null && plain != null && hundred != 0) {
    final ratio = (plain / hundred).abs();
    if (ratio > 5 && ratio < 15) return plain;
  }
  return hundred ?? plain;
}

String formatLookupNumber(num value) {
  final asDouble = value.toDouble();
  if (asDouble == asDouble.roundToDouble()) return asDouble.round().toString();
  var text = asDouble.toStringAsFixed(2);
  while (text.endsWith('0')) {
    text = text.substring(0, text.length - 1);
  }
  if (text.endsWith('.')) text = text.substring(0, text.length - 1);
  return text;
}

FoodForm guessLookupForm(String name, String quantity) {
  final text = '${name.toLowerCase()} ${quantity.toLowerCase()}';
  if (text.contains('冻干') || text.contains('freeze')) {
    return FoodForm.freezeDried;
  }
  if (text.contains('零食') || text.contains('treat') || text.contains('snack')) {
    return FoodForm.treat;
  }
  if (text.contains('罐') || text.contains('can') || text.contains('mousse')) {
    return FoodForm.can;
  }
  if (text.contains('湿') ||
      text.contains('pouch') ||
      text.contains('gravy') ||
      text.contains('jelly')) {
    return FoodForm.wet;
  }
  return FoodForm.dry;
}

Map<dynamic, dynamic>? _jsonMap(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map) return decoded;
  } catch (_) {}
  return null;
}

String _firstText(Map<dynamic, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return '';
}

String _collapse(String raw) {
  return raw.replaceAll(RegExp(r'\s+'), ' ').trim();
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String _quantityHint(String text) {
  final match = RegExp(
    r'\d+(?:\.\d+)?\s*(?:kg|g|ml|l|千克|克|毫升|升)',
    caseSensitive: false,
  ).firstMatch(text);
  return match?.group(0) ?? '';
}

const _juheAuthErrors = <int>{
  10001,
  10002,
  10003,
  10004,
  10005,
  10007,
  10008,
  10009,
  10011,
  10012,
  10013,
};

SourceReply _juheReply(int status, String body, String requested) {
  if (status == 401 || status == 403) return const SourceReply.skip();
  if (status != 200 || body.isEmpty) return const SourceReply.miss();
  final decoded = _jsonMap(body);
  if (decoded == null) return const SourceReply.skip();
  final error = _asInt(decoded['error_code']);
  if (error != null && _juheAuthErrors.contains(error)) {
    return const SourceReply.skip();
  }
  final result = decoded['result'];
  if (result is Map) {
    final record = _goodsRecord(result, requested, 'juhe');
    if (record != null) return SourceReply.hit(record);
  }
  return const SourceReply.miss();
}

SourceReply _showapiReply(int status, String body, String requested) {
  if (status == 400 || status == 401 || status == 403) {
    return const SourceReply.skip();
  }
  if (status != 200 || body.isEmpty) return const SourceReply.miss();
  final decoded = _jsonMap(body);
  if (decoded == null) return const SourceReply.skip();
  final code = decoded['showapi_res_code'];
  if (code != 0 && code != '0') return const SourceReply.skip();
  final payload = decoded['showapi_res_body'];
  if (payload is! Map) return const SourceReply.miss();
  final flag = payload['flag'];
  final ret = '${payload['ret_code'] ?? ''}';
  if (flag == false || flag == 'false' || (ret.isNotEmpty && ret != '0')) {
    return const SourceReply.miss();
  }
  final record = _goodsRecord(payload, requested, 'aliyun');
  if (record == null) return const SourceReply.miss();
  return SourceReply.hit(record);
}

SourceReply _topthinkReply(int status, String body, String requested) {
  if (status == 401 || status == 403) return const SourceReply.skip();
  if (status != 200 || body.isEmpty) return const SourceReply.miss();
  final decoded = _jsonMap(body);
  if (decoded == null) return const SourceReply.skip();
  final message = _firstText(decoded, const ['message']);
  if (message.contains('令牌') || message.contains('授权')) {
    return const SourceReply.skip();
  }
  final code = decoded['code'];
  final data = decoded['data'];
  if ((code == 0 || code == '0') && data is Map) {
    final record = _goodsRecord(data, requested, 'topthink');
    if (record != null) return SourceReply.hit(record);
  }
  return const SourceReply.miss();
}

SourceReply parseProductGuru(String body, String requested) {
  final decoded = _jsonMap(body);
  if (decoded == null) return const SourceReply.skip();
  if (decoded['error'] != null) return const SourceReply.miss();
  final name = _firstText(decoded, const ['name']);
  final brand = _firstText(decoded, const ['brand']);
  if (name.isEmpty && brand.isEmpty) return const SourceReply.miss();
  final web = _firstText(decoded, const ['web_url']);
  return SourceReply.hit(
    BarcodeRecord(
      code: requested,
      found: true,
      brand: brand,
      name: name.isEmpty ? brand : name,
      quantity: _firstText(decoded, const ['quantity']),
      ingredients: '',
      nutrients: const [],
      source: 'productguru',
      sourceUrl: web.isEmpty ? 'https://myproduct.guru' : web,
    ),
  );
}

SourceReply parseGoUpc(String body, String requested) {
  final decoded = _jsonMap(body);
  if (decoded == null) return const SourceReply.skip();
  final product = decoded['product'];
  if (product is! Map) return const SourceReply.miss();
  final name = _firstText(product, const ['name']);
  final brand = _firstText(product, const ['brand']);
  if (name.isEmpty && brand.isEmpty) return const SourceReply.miss();
  final ingredients = product['ingredients'];
  final ingredientText = ingredients is Map
      ? _collapse(_firstText(ingredients, const ['text']))
      : '';
  var quantity = '';
  final specs = product['specs'];
  if (specs is List) {
    for (final spec in specs) {
      if (spec is! List || spec.length < 2) continue;
      final label = '${spec[0]}'.toLowerCase();
      if (label.contains('weight') ||
          label.contains('size') ||
          label.contains('net')) {
        quantity = '${spec[1]}'.trim();
        break;
      }
    }
  }
  if (quantity.isEmpty) {
    quantity = _quantityHint('$name ${product['description'] ?? ''}');
  }
  return SourceReply.hit(
    BarcodeRecord(
      code: requested,
      found: true,
      brand: brand,
      name: name.isEmpty ? brand : name,
      quantity: quantity,
      ingredients: ingredientText,
      nutrients: const [],
      imageUrl: _httpUrl(_firstText(product, const ['imageUrl'])),
      source: 'goupc',
    ),
  );
}

SourceReply parseEanSearch(String body, String requested) {
  final dynamic decoded;
  try {
    decoded = jsonDecode(body);
  } catch (_) {
    return const SourceReply.skip();
  }
  if (decoded is Map && decoded['error'] != null) {
    return const SourceReply.skip();
  }
  if (decoded is! List || decoded.isEmpty) return const SourceReply.miss();
  final first = decoded.first;
  if (first is! Map) return const SourceReply.miss();
  if (first['error'] != null) return const SourceReply.skip();
  final name = _firstText(first, const ['name']);
  if (name.isEmpty) return const SourceReply.miss();
  return SourceReply.hit(
    BarcodeRecord(
      code: requested,
      found: true,
      brand: '',
      name: name,
      quantity: _quantityHint(name),
      ingredients: '',
      nutrients: const [],
      source: 'eansearch',
    ),
  );
}

BarcodeRecord? _goodsRecord(
  Map<dynamic, dynamic> json,
  String requested,
  String source,
) {
  final name = _firstText(json, const ['goodsName', 'name', 'title']);
  var brand = _firstText(json, const ['trademark', 'brand', 'brandName']);
  if (brand.isEmpty) brand = _firstText(json, const ['manuName']);
  if (name.isEmpty && brand.isEmpty) return null;
  return BarcodeRecord(
    code: requested,
    found: true,
    brand: brand,
    name: name.isEmpty ? brand : name,
    quantity: _firstText(json, const ['spec', 'standard', 'quantity']),
    ingredients: '',
    nutrients: const [],
    imageUrl: _httpUrl(
      _firstText(json, const ['img', 'imgUrl', 'image', 'imageUrl']),
    ),
    source: source,
  );
}

String? _httpUrl(String raw) {
  final url = raw.trim();
  if (url.startsWith('https://') || url.startsWith('http://')) return url;
  return null;
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}
