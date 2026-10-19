import 'dart:convert';

import '../models.dart';

/// Settings key. Drafts live in the same [AppSettings] table as barcode
/// memory, not in a second database.
const recognitionDraftsKey = 'recognitionDrafts';

/// How many unfinished scans and photos to keep on this phone.
const maxRecognitionDrafts = 20;

/// A scan or pack photo the person has not finished confirming.
///
/// Stored locally and readable after the screen is closed. A future account
/// sync can push [RecognitionDraft.toSyncJson] as entity `recognition_draft`
/// through the existing outbox. This build does not contact a server for
/// drafts: [CloudBridge] still no-ops without a cloud token, and these rows
/// are not enqueued, so an unknown entity cannot stall other sync.
class RecognitionDraft {
  const RecognitionDraft({
    required this.id,
    required this.kind,
    required this.updatedAt,
    this.barcode = '',
    this.brand = '',
    this.name = '',
    this.spec = '',
    this.flavor = '',
    this.formKey = '',
    this.customForm = '',
    this.ingredients = '',
    this.photoPath,
    this.production,
    this.expiry,
    this.expiryFromOcr = false,
    this.productId,
    this.pantryId,
    this.addBag = false,
    this.marks = const {},
    this.failure = '',
  });

  /// `code:<barcodeKey>`, `photo:<path>`, or `latest` when nothing else identifies it.
  final String id;

  /// `scan`, `ocr`, `confirm`, or `facts` (saved ingredients, not shown as unfinished).
  final String kind;
  final DateTime updatedAt;
  final String barcode;
  final String brand;
  final String name;
  final String spec;
  final String flavor;
  final String formKey;
  final String customForm;
  final String ingredients;
  final String? photoPath;
  final DateTime? production;
  final DateTime? expiry;
  final bool expiryFromOcr;
  final int? productId;
  final int? pantryId;
  final bool addBag;

  /// Field key → `recognized` / `review` / `missing` / `edited`.
  final Map<String, String> marks;

  /// `camera`, `empty`, `low`, or empty when the form has a read.
  final String failure;

  bool get unfinished => kind != 'facts';

  bool get isBlank =>
      barcode.trim().isEmpty &&
      brand.trim().isEmpty &&
      name.trim().isEmpty &&
      spec.trim().isEmpty &&
      ingredients.trim().isEmpty &&
      (photoPath == null || photoPath!.isEmpty) &&
      production == null &&
      expiry == null &&
      failure.trim().isEmpty;

  String get title {
    final named = [
      brand.trim(),
      name.trim(),
    ].where((part) => part.isNotEmpty).join(' ');
    if (named.isNotEmpty) return named;
    if (barcode.trim().isNotEmpty) return barcode.trim();
    return '未命名';
  }

  String get resumeRoute {
    final params = <String>[
      if (barcode.trim().isNotEmpty)
        'code=${Uri.encodeComponent(barcode.trim())}',
      'draft=${Uri.encodeComponent(id)}',
      if (addBag && kind != 'confirm') 'bag=1',
      if (productId != null && kind == 'confirm') 'product=$productId',
      if (kind == 'confirm' && productId == null && brand.trim().isEmpty)
        'blank=1',
    ];
    final query = params.join('&');
    if (kind == 'confirm') return '/confirm?$query';
    if (kind == 'ocr' || kind == 'pack') return '/pack?$query';
    return '/food?$query';
  }

  /// Payload a future account sync can send. Not transmitted in this build.
  Map<String, Object?> toSyncJson() => toJson();

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'barcode': barcode,
    'brand': brand,
    'name': name,
    'spec': spec,
    'flavor': flavor,
    'formKey': formKey,
    'customForm': customForm,
    'ingredients': ingredients,
    'photoPath': photoPath,
    'production': production?.toIso8601String(),
    'expiry': expiry?.toIso8601String(),
    'expiryFromOcr': expiryFromOcr,
    'productId': productId,
    'pantryId': pantryId,
    'addBag': addBag,
    'marks': marks,
    'failure': failure,
  };

  factory RecognitionDraft.fromJson(Map<dynamic, dynamic> json) {
    final updated = DateTime.tryParse('${json['updatedAt'] ?? ''}');
    return RecognitionDraft(
      id: '${json['id'] ?? ''}',
      kind: '${json['kind'] ?? 'ocr'}',
      updatedAt: (updated ?? DateTime.now()).toUtc(),
      barcode: '${json['barcode'] ?? ''}',
      brand: '${json['brand'] ?? ''}',
      name: '${json['name'] ?? ''}',
      spec: '${json['spec'] ?? ''}',
      flavor: '${json['flavor'] ?? ''}',
      formKey: '${json['formKey'] ?? ''}',
      customForm: '${json['customForm'] ?? ''}',
      ingredients: '${json['ingredients'] ?? ''}',
      photoPath: json['photoPath'] is String
          ? json['photoPath'] as String
          : null,
      production: DateTime.tryParse('${json['production'] ?? ''}'),
      expiry: DateTime.tryParse('${json['expiry'] ?? ''}'),
      expiryFromOcr: json['expiryFromOcr'] == true,
      productId: _asInt(json['productId']),
      pantryId: _asInt(json['pantryId']),
      addBag: json['addBag'] == true,
      marks: _marks(json['marks']),
      failure: '${json['failure'] ?? ''}',
    );
  }

  /// Fills only the fields [incoming] actually has, so a bare scan does not
  /// wipe a photo that was already read for the same barcode.
  RecognitionDraft overlay(RecognitionDraft incoming) {
    String pick(String next, String kept) {
      final text = next.trim();
      return text.isNotEmpty ? text : kept;
    }

    return RecognitionDraft(
      id: id,
      kind: incoming.kind.isEmpty ? kind : incoming.kind,
      updatedAt: incoming.updatedAt,
      barcode: pick(incoming.barcode, barcode),
      brand: pick(incoming.brand, brand),
      name: pick(incoming.name, name),
      spec: pick(incoming.spec, spec),
      flavor: pick(incoming.flavor, flavor),
      formKey: pick(incoming.formKey, formKey),
      customForm: pick(incoming.customForm, customForm),
      ingredients: pick(incoming.ingredients, ingredients),
      photoPath: pick(incoming.photoPath ?? '', photoPath ?? '').isEmpty
          ? null
          : pick(incoming.photoPath ?? '', photoPath ?? ''),
      production: incoming.production ?? production,
      expiry: incoming.expiry ?? expiry,
      expiryFromOcr: incoming.expiryFromOcr || expiryFromOcr,
      productId: incoming.productId ?? productId,
      pantryId: incoming.pantryId ?? pantryId,
      addBag: incoming.addBag || addBag,
      marks: incoming.marks.isEmpty ? marks : incoming.marks,
      failure: incoming.failure.trim().isEmpty ? failure : incoming.failure,
    );
  }
}

int? _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse('$value');
}

Map<String, String> _marks(Object? raw) {
  if (raw is! Map) return const {};
  final out = <String, String>{};
  for (final entry in raw.entries) {
    final value = '${entry.value}'.trim();
    if (value.isEmpty) continue;
    out['${entry.key}'] = value;
  }
  return out;
}

String recognitionDraftId({String barcode = '', String? photoPath}) {
  final digits = barcode.replaceAll(RegExp(r'\D'), '');
  final trimmed = digits.replaceFirst(RegExp(r'^0+'), '');
  if (trimmed.isNotEmpty) return 'code:$trimmed';
  final photo = photoPath?.trim() ?? '';
  if (photo.isNotEmpty) return 'photo:$photo';
  return 'latest';
}

List<RecognitionDraft> decodeRecognitionDrafts(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return [
      for (final item in decoded)
        if (item is Map) RecognitionDraft.fromJson(item),
    ];
  } catch (_) {
    return [];
  }
}

String encodeRecognitionDrafts(List<RecognitionDraft> drafts) {
  return jsonEncode([for (final draft in drafts) draft.toJson()]);
}

/// Newest first. [merge] keeps earlier field values when the new row is sparse.
List<RecognitionDraft> upsertRecognitionDraft(
  List<RecognitionDraft> drafts,
  RecognitionDraft incoming, {
  bool merge = false,
}) {
  if (incoming.id.isEmpty || incoming.isBlank) return drafts;
  final next = <RecognitionDraft>[];
  var wrote = false;
  for (final draft in drafts) {
    if (draft.id != incoming.id) {
      next.add(draft);
      continue;
    }
    next.add(merge ? draft.overlay(incoming) : incoming);
    wrote = true;
  }
  if (!wrote) next.add(incoming);
  next.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  if (next.length <= maxRecognitionDrafts) return next;
  return next.sublist(0, maxRecognitionDrafts);
}

List<RecognitionDraft> dropRecognitionDraft(
  List<RecognitionDraft> drafts,
  String id,
) {
  return [
    for (final draft in drafts)
      if (draft.id != id) draft,
  ];
}

FoodForm formFromDraft(RecognitionDraft draft) {
  if (draft.formKey.isEmpty) return FoodForm.dry;
  return parseFoodForm(draft.formKey);
}
