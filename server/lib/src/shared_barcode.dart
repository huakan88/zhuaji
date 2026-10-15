/// A cat-food barcode contributed by a phone. Newer [updatedAt] wins.
/// Equal timestamps keep the lexicographically greater [contributorId].
class SharedBarcode {
  const SharedBarcode({
    required this.barcode,
    required this.brand,
    required this.name,
    required this.spec,
    required this.ingredients,
    required this.contributorId,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
  });

  final String barcode;
  final String brand;
  final String name;
  final String spec;
  final String ingredients;
  final String? imageUrl;
  final String contributorId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => {
    'barcode': barcode,
    'brand': brand,
    'name': name,
    'spec': spec,
    'ingredients': ingredients,
    'imageUrl': imageUrl,
    'contributorId': contributorId,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  /// Digits only, leading zeros removed, so UPC and EAN forms match.
  static String canonical(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^\d{8}$|^\d{12}$|^\d{13}$|^\d{14}$').hasMatch(digits)) {
      return '';
    }
    final trimmed = digits.replaceFirst(RegExp(r'^0+'), '');
    return trimmed.isEmpty ? '0' : trimmed;
  }

  static SharedBarcode? parse(Map<String, Object?> json) {
    final barcode = canonical('${json['barcode'] ?? ''}');
    final brand = _clip(json['brand'], 40);
    final name = _clip(json['name'], 80);
    final spec = _clip(json['spec'], 40);
    final contributorId = _clip(json['contributorId'], 64);
    final updatedAt = DateTime.tryParse('${json['updatedAt'] ?? ''}')?.toUtc();
    final createdRaw = DateTime.tryParse('${json['createdAt'] ?? ''}')?.toUtc();
    if (barcode.isEmpty ||
        brand.isEmpty ||
        name.isEmpty ||
        spec.isEmpty ||
        contributorId.isEmpty ||
        updatedAt == null) {
      return null;
    }
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(contributorId)) return null;
    final image = _image(json['imageUrl']);
    if (json['imageUrl'] != null &&
        '${json['imageUrl']}'.trim().isNotEmpty &&
        image == null) {
      return null;
    }
    return SharedBarcode(
      barcode: barcode,
      brand: brand,
      name: name,
      spec: spec,
      ingredients: _clip(json['ingredients'], 500),
      imageUrl: image,
      contributorId: contributorId,
      createdAt: createdRaw ?? updatedAt,
      updatedAt: updatedAt,
    );
  }

  /// The row that should stay. A first write is always applied.
  static ({SharedBarcode row, bool applied}) keep(
    SharedBarcode? stored,
    SharedBarcode incoming,
  ) {
    if (stored == null) return (row: incoming, applied: true);
    final newer = incoming.updatedAt.isAfter(stored.updatedAt);
    final tie =
        incoming.updatedAt.isAtSameMomentAs(stored.updatedAt) &&
        incoming.contributorId.compareTo(stored.contributorId) > 0;
    if (!newer && !tie) return (row: stored, applied: false);
    return (
      row: SharedBarcode(
        barcode: stored.barcode,
        brand: incoming.brand,
        name: incoming.name,
        spec: incoming.spec,
        ingredients: incoming.ingredients,
        imageUrl: incoming.imageUrl,
        contributorId: incoming.contributorId,
        createdAt: stored.createdAt,
        updatedAt: incoming.updatedAt,
      ),
      applied: true,
    );
  }
}

String _clip(Object? raw, int max) {
  final text = '${raw ?? ''}'.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (text.length <= max) return text;
  return text.substring(0, max);
}

String? _image(Object? raw) {
  if (raw == null) return null;
  final text = '$raw'.trim();
  if (text.isEmpty) return null;
  final uri = Uri.tryParse(text);
  if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
    return null;
  }
  if (text.length > 300) return null;
  return text;
}
