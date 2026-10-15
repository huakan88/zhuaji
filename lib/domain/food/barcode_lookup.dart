import 'dart:convert';

import '../models.dart';

/// One HTTP reply from a public product database.
class BarcodeResponse {
  const BarcodeResponse(this.status, this.body);

  final int status;
  final String body;
}

typedef BarcodeFetch = Future<BarcodeResponse> Function(Uri uri);

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
    this.kcalPer100g,
    this.offline = false,
  });

  final String code;
  final bool found;
  final bool offline;
  final String brand;
  final String name;
  final String quantity;
  final String ingredients;
  final List<BarcodeNutrient> nutrients;
  final String? imageUrl;

  /// `openpetfoodfacts`, `openfoodfacts`, `openproductsfacts`, or `upcitemdb`.
  final String source;
  final double? kcalPer100g;

  String get sourceLabel => switch (source) {
    'openpetfoodfacts' => 'Open Pet Food Facts',
    'openfoodfacts' => 'Open Food Facts',
    'openproductsfacts' => 'Open Products Facts',
    'upcitemdb' => 'UPCitemdb',
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
    'source': source,
    'kcalPer100g': kcalPer100g,
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
      source: '${json['source'] ?? ''}',
      kcalPer100g: kcal is num ? kcal.toDouble() : null,
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

/// Open Pet Food Facts, then Open Food Facts, then Open Products Facts,
/// then the UPCitemdb trial lookup. The first database that names the
/// product wins. A total miss is cached by the caller; a network failure
/// is marked [BarcodeRecord.offline] and should not be cached.
///
/// 中国物品编码中心没有免登录的公开接口，企业查询要申请密钥，这里不调用。
Future<BarcodeRecord> lookupBarcode(
  String code, {
  required BarcodeFetch fetch,
}) async {
  final requested = code.trim();
  final candidates = barcodeCandidates(requested);
  var reached = false;

  Future<BarcodeRecord?> ask(
    Uri uri,
    BarcodeRecord? Function(String body) parse,
  ) async {
    try {
      final response = await fetch(uri);
      if (response.status <= 0) return null;
      reached = true;
      if (response.status != 200 || response.body.isEmpty) return null;
      return parse(response.body);
    } catch (_) {
      return null;
    }
  }

  for (final source in _openFacts) {
    for (final candidate in candidates) {
      final hit = await ask(
        Uri.parse('${source.$2}$candidate'),
        (body) => parseOpenFacts(body, source.$1, requested),
      );
      if (hit != null) return hit;
    }
  }
  for (final candidate in candidates) {
    final hit = await ask(
      Uri.https('api.upcitemdb.com', '/prod/trial/lookup', {'upc': candidate}),
      (body) => parseUpcItemDb(body, requested),
    );
    if (hit != null) return hit;
  }
  if (!reached) return BarcodeRecord.offline(requested);
  return BarcodeRecord.miss(requested);
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
