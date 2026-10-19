import '../dates.dart';
import '../food_options.dart';
import '../models.dart';
import 'ocr_date_parser.dart';
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
  const PackRead({
    this.brand,
    this.name,
    this.flavor,
    this.form,
    this.spec,
    this.ingredients,
    this.productionDate,
    this.expiryDate,
    this.expiryUncertain = false,
  });

  final String? brand;
  final String? name;
  final String? flavor;
  final FoodForm? form;
  final String? spec;
  final String? ingredients;
  final DateTime? productionDate;
  final DateTime? expiryDate;

  /// An expiry label was seen, but the date was not confident enough to keep.
  final bool expiryUncertain;

  bool get isEmpty =>
      brand == null &&
      name == null &&
      flavor == null &&
      form == null &&
      spec == null &&
      ingredients == null &&
      productionDate == null &&
      expiryDate == null;
}

/// Reads a front-of-pack photo's OCR text into brand, name, flavor, form
/// and pack size. The user confirms; nothing here is saved on its own.
class PackFrontParser {
  const PackFrontParser();

  PackRead parse(
    String raw, {
    List<String> extraBrands = const [],
    List<OcrLine> lines = const [],
  }) {
    final source = lines.isEmpty
        ? [
            for (final line in halfWidth(raw).split(RegExp(r'\r?\n')))
              if (line.trim().isNotEmpty) line.trim(),
          ]
        : [
            for (final row in rowsFromLines([
              for (final line in lines)
                OcrLine(
                  halfWidth(line.text),
                  left: line.left,
                  top: line.top,
                  right: line.right,
                  bottom: line.bottom,
                  confidence: line.confidence,
                ),
            ]))
              if (row.trim().isNotEmpty) row.trim(),
          ];
    if (source.isEmpty) return const PackRead();
    final dated = lines.isEmpty
        ? const OcrDateParser().parse(source.join('\n'))
        : const OcrDateParser().parseLines([
            for (final line in lines)
              OcrLine(
                halfWidth(line.text),
                left: line.left,
                top: line.top,
                right: line.right,
                bottom: line.bottom,
                confidence: line.confidence,
              ),
          ]);
    final front = _withoutBlocks(source);
    final text = front.join('\n');
    final brands = [
      ...packBrands,
      for (final extra in extraBrands) _extra(extra),
    ];
    final brandHit = _findBrand(front, brands);
    final labeledBrand = _canonicalBrand(
      _after(source, const ['品牌', 'BRAND']),
      brands,
    );
    final labeledName = _after(source, const ['产品名称', '品名', '名称']);
    final labeledSpec = _spec(
      _after(source, const ['净含量', '规格', 'NET WEIGHT', 'NET WT']) ?? '',
    );
    final ingredients = _ingredients(source);
    return PackRead(
      brand: labeledBrand ?? brandHit?.canonical,
      name: _clean(labeledName) ?? _name(front, brandHit),
      flavor: _flavor(text),
      form: _form(text),
      spec: labeledSpec ?? _spec(text),
      ingredients: ingredients,
      productionDate: dated.productionDate == null
          ? null
          : dateOnly(dated.productionDate!),
      expiryDate: dated.expiryDate == null ? null : dateOnly(dated.expiryDate!),
      expiryUncertain: dated.uncertain && dated.expiryDate == null,
    );
  }

  String? _clean(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 2) return null;
    return text;
  }

  String? _canonicalBrand(String? labeled, List<PackBrand?> brands) {
    final text = _clean(labeled);
    if (text == null) return null;
    for (final brand in brands) {
      if (brand == null) continue;
      for (final alias in brand.aliases) {
        if (_indexOf(text, alias) >= 0) return brand.canonical;
      }
    }
    return text;
  }

  /// Drops ingredient and date lines so they are not reused as the product name.
  List<String> _withoutBlocks(List<String> lines) {
    final kept = <String>[];
    var skipping = false;
    for (final line in lines) {
      if (_ingredientStart(line) != null || _dateLine(line)) {
        skipping = _ingredientStart(line) != null;
        continue;
      }
      if (skipping) {
        if (_sectionStop(line) || _fieldLabel(line) != null) {
          skipping = false;
          if (_fieldLabel(line) != null) continue;
        } else {
          continue;
        }
      }
      kept.add(line);
    }
    return kept;
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
    if (_fieldLabel(line) != null || _dateLine(line) || _ingredientStart(line) != null) {
      return true;
    }
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
      '品牌',
      '品名',
    ];
    final lower = line.toLowerCase();
    if (keys.any(lower.contains)) return true;
    if (RegExp(
      r'(^|[\s:：])(exp|expiry|mfg|mfd|bbe|bbd)($|[\s:：.])',
      caseSensitive: false,
    ).hasMatch(lower)) {
      return true;
    }
    if (RegExp(r'^[\d\s./\-]+$').hasMatch(line)) return true;
    return false;
  }

  String? _fieldLabel(String line) {
    const labels = ['产品名称', '品名', '品牌', '净含量', '规格', '名称', 'BRAND'];
    final trimmed = line.trim();
    for (final label in labels) {
      if (_atStart(trimmed, label)) return label;
    }
    return null;
  }

  bool _dateLine(String line) {
    const labels = [
      '生产日期',
      '制造日期',
      '到期时间',
      '到期日期',
      '到期日',
      '保质期',
      '有效期',
      'MFG',
      'MFD',
      'EXP',
      'EXPIRY',
      'BEST BEFORE',
      'USE BY',
    ];
    for (final label in labels) {
      if (_atStart(line.trim(), label)) return true;
    }
    return false;
  }

  bool _sectionStop(String line) {
    const stops = [
      '营养成分',
      '保证成分',
      '成分分析',
      '成分保证',
      '生产日期',
      '保质期',
      '到期',
      '贮存',
      '储存',
      '净含量',
      '产品标准',
      '饲喂',
      '使用方法',
    ];
    final trimmed = line.trim();
    for (final stop in stops) {
      if (_atStart(trimmed, stop)) return true;
    }
    return false;
  }

  bool _atStart(String line, String label) {
    final ascii = RegExp(r"^[A-Za-z0-9 '&]+$").hasMatch(label);
    final hay = ascii ? line.toUpperCase() : line;
    final needle = ascii ? label.toUpperCase() : label;
    if (!hay.startsWith(needle)) return false;
    if (hay.length == needle.length) return true;
    final next = hay.substring(needle.length, needle.length + 1);
    return RegExp(r'[\s:：/|]').hasMatch(next);
  }

  String? _after(List<String> lines, List<String> labels) {
    for (var i = 0; i < lines.length; i++) {
      for (final label in labels) {
        if (!_atStart(lines[i].trim(), label)) continue;
        final ascii = RegExp(r"^[A-Za-z0-9 '&]+$").hasMatch(label);
        final line = lines[i].trim();
        final hay = ascii ? line.toUpperCase() : line;
        final needle = ascii ? label.toUpperCase() : label;
        var rest = line.substring(needle.length).replaceFirst(RegExp(r'^[\s:：]+'), '').trim();
        if (ascii) {
          final index = hay.indexOf(needle);
          rest = line.substring(index + needle.length).replaceFirst(RegExp(r'^[\s:：]+'), '').trim();
        }
        if (rest.isEmpty && i + 1 < lines.length && _fieldLabel(lines[i + 1]) == null && !_dateLine(lines[i + 1])) {
          rest = lines[i + 1].trim();
        }
        if (rest.isNotEmpty) return rest;
      }
    }
    return null;
  }

  String? _ingredientStart(String line) {
    const labels = ['配料表', '原料组成', '配料', 'INGREDIENTS'];
    for (final label in labels) {
      if (_atStart(line.trim(), label)) return label;
    }
    return null;
  }

  String? _ingredients(List<String> lines) {
    for (var i = 0; i < lines.length; i++) {
      final label = _ingredientStart(lines[i]);
      if (label == null) continue;
      final chunks = <String>[];
      final head = lines[i].trim();
      final ascii = RegExp(r"^[A-Za-z0-9 '&]+$").hasMatch(label);
      final hay = ascii ? head.toUpperCase() : head;
      final needle = ascii ? label.toUpperCase() : label;
      final index = hay.indexOf(needle);
      final rest = head.substring(index + needle.length).replaceFirst(RegExp(r'^[\s:：]+'), '').trim();
      if (rest.isNotEmpty) chunks.add(rest);
      for (var j = i + 1; j < lines.length; j++) {
        if (_sectionStop(lines[j]) || _fieldLabel(lines[j]) != null) break;
        final piece = lines[j].trim();
        if (piece.isEmpty) continue;
        chunks.add(piece);
        if (chunks.join().length > 500) break;
      }
      final text = chunks.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
      if (text.isEmpty) return null;
      return text.length > 500 ? text.substring(0, 500) : text;
    }
    return null;
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
