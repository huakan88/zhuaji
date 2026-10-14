import '../food_options.dart';
import '../models.dart';
import 'ocr_lines.dart';

class PackBrand {
  const PackBrand(this.canonical, this.aliases);

  final String canonical;
  final List<String> aliases;
}

/// Brands the pack reader knows even when the local catalog has not loaded.
const packBrands = <PackBrand>[
  PackBrand('皇家 Royal Canin', ['皇家', 'ROYAL CANIN', 'ROYALCANIN']),
  PackBrand('Orijen 渴望', ['渴望', 'ORIJEN']),
  PackBrand('Acana 爱肯拿', ['爱肯拿', 'ACANA']),
  PackBrand("Hill's 希尔斯", ["HILL'S", 'HILLS', '希尔斯', '希尔思']),
  PackBrand('百利 Instinct', ['百利', 'INSTINCT']),
  PackBrand('麦富迪 Myfoodie', ['麦富迪', 'MYFOODIE']),
  PackBrand('网易严选', ['网易严选']),
  PackBrand('小佩 PETKIT', ['小佩', 'PETKIT']),
  PackBrand('诚实一口', ['诚实一口']),
];

class PackRead {
  const PackRead({this.brand, this.name, this.flavor, this.form, this.spec});

  final String? brand;
  final String? name;
  final String? flavor;
  final FoodForm? form;
  final String? spec;

  bool get isEmpty =>
      brand == null && name == null && flavor == null && form == null && spec == null;
}

/// Reads a front-of-pack photo's OCR text into brand, name, flavor, form
/// and pack size. The user confirms; nothing here is saved on its own.
class PackFrontParser {
  const PackFrontParser();

  PackRead parse(String raw, {List<String> extraBrands = const []}) {
    final lines = [
      for (final line in halfWidth(raw).split(RegExp(r'\r?\n')))
        if (line.trim().isNotEmpty) line.trim(),
    ];
    if (lines.isEmpty) return const PackRead();
    final text = lines.join('\n');
    final brands = [...packBrands, for (final extra in extraBrands) _extra(extra)];
    final brandHit = _findBrand(lines, brands);
    return PackRead(
      brand: brandHit?.canonical,
      name: _name(lines, brandHit),
      flavor: _flavor(text),
      form: _form(text),
      spec: _spec(text),
    );
  }

  PackBrand? _extra(String brand) {
    final trimmed = brand.trim();
    if (trimmed.isEmpty) return null;
    final cjk = RegExp(r'[\u4e00-\u9fff]{2,}').allMatches(trimmed).map((m) => m.group(0)!);
    return PackBrand(trimmed, {trimmed, ...cjk}.toList());
  }

  _BrandHit? _findBrand(List<String> lines, List<PackBrand?> brands) {
    _BrandHit? best;
    for (var i = 0; i < lines.length; i++) {
      if (_noise(lines[i])) continue;
      for (final brand in brands) {
        if (brand == null) continue;
        for (final alias in brand.aliases) {
          final found = _indexOf(lines[i], alias);
          if (found < 0) continue;
          final hit = _BrandHit(
            canonical: brand.canonical,
            line: i,
            start: found,
            length: alias.length,
          );
          if (best == null || hit.length > best.length) best = hit;
        }
      }
    }
    if (best != null) return best;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (_noise(line) || _flavor(line) == line || _form(line) != null && line.length <= 4) {
        continue;
      }
      if (RegExp(r'^[\u4e00-\u9fffA-Za-z]{2,10}$').hasMatch(line)) {
        return _BrandHit(canonical: line, line: i, start: 0, length: line.length);
      }
    }
    return null;
  }

  int _indexOf(String line, String alias) {
    final ascii = RegExp(r"^[A-Za-z0-9 '&]+$").hasMatch(alias);
    final hay = ascii ? line.toUpperCase() : line;
    final needle = ascii ? alias.toUpperCase() : alias;
    return hay.indexOf(needle);
  }

  String? _name(List<String> lines, _BrandHit? brand) {
    final candidates = <String>[];
    if (brand != null) {
      final line = lines[brand.line];
      final rest = (line.substring(0, brand.start) + line.substring(brand.start + brand.length))
          .replaceAll(RegExp(r'^[\s·|/\\\-]+|[\s·|/\\\-]+$'), '')
          .trim();
      if (rest.length >= 2) candidates.add(rest);
    }
    for (var i = 0; i < lines.length; i++) {
      if (brand != null && i == brand.line) continue;
      final line = lines[i];
      if (_noise(line)) continue;
      if (_flavor(line) == line) continue;
      if (line.length < 2 || line.length > 24) continue;
      candidates.add(line);
    }
    for (final item in candidates) {
      if (RegExp('猫|全价|主食|成猫|幼猫|粮').hasMatch(item)) return item;
    }
    for (final item in candidates) {
      if (_form(item) != null && item.length <= 3) continue;
      return item;
    }
    return null;
  }

  String? _flavor(String text) {
    for (final flavor in foodFlavors) {
      if (text.contains(flavor)) return flavor;
    }
    return null;
  }

  FoodForm? _form(String text) {
    if (text.contains('主食罐') || text.contains('主食罐头')) return FoodForm.can;
    if (text.contains('冻干')) return FoodForm.freezeDried;
    if (text.contains('零食') || text.contains('猫条') || text.contains('肉条')) {
      return FoodForm.treat;
    }
    if (text.contains('湿粮') || text.contains('妙鲜包') || text.contains('餐包') || text.contains('罐头')) {
      return FoodForm.wet;
    }
    if (text.contains('干粮') || text.contains('猫粮') || text.contains('全价')) {
      return FoodForm.dry;
    }
    return null;
  }

  String? _spec(String text) {
    final match = RegExp(
      r'(\d+(?:\.\d+)?)\s*(kg|g|ml|千克|克|毫升)',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) return null;
    final number = double.parse(match.group(1)!);
    final unit = switch (match.group(2)!.toLowerCase()) {
      '千克' || 'kg' => 'kg',
      '毫升' || 'ml' => 'ml',
      _ => 'g',
    };
    final shown = number == number.roundToDouble()
        ? number.toStringAsFixed(0)
        : number.toString();
    return '$shown$unit';
  }

  bool _noise(String line) {
    const keys = [
      '净含量',
      '生产日期',
      '保质期',
      '配料',
      '成分',
      '保证值',
      '贮存',
      '储存',
      '产品标准',
      '许可证',
      '原产',
      '进口商',
      '地址',
      '网址',
      'http',
      '电话',
      '饲喂',
      '生产商',
      '条形码',
      '二维码',
    ];
    final lower = line.toLowerCase();
    if (keys.any(lower.contains)) return true;
    if (RegExp(r'^[\d\s]+$').hasMatch(line)) return true;
    return false;
  }
}

class _BrandHit {
  const _BrandHit({
    required this.canonical,
    required this.line,
    required this.start,
    required this.length,
  });

  final String canonical;
  final int line;
  final int start;
  final int length;
}
