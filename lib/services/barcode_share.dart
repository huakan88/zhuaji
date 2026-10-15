import 'dart:convert';
import 'dart:io';

import '../domain/food/barcode_lookup.dart';
import 'barcode_client.dart';

const _shareUrl = String.fromEnvironment('BARCODE_SHARE_URL');
const _shareKey = String.fromEnvironment('BARCODE_SHARE_KEY');

/// Where user corrections are published. Empty [baseUrl] means this phone
/// keeps corrections locally and does not call a server.
class BarcodeShare {
  const BarcodeShare({this.baseUrl = '', this.key = ''});

  final String baseUrl;
  final String key;

  bool get enabled => baseUrl.trim().isNotEmpty;

  factory BarcodeShare.fromEnvironment() {
    String pick(String name, String compiled) {
      final env = Platform.environment[name]?.trim() ?? '';
      if (env.isNotEmpty) return env;
      return compiled.trim();
    }

    var url = pick('BARCODE_SHARE_URL', _shareUrl);
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    return BarcodeShare(
      baseUrl: url,
      key: pick('BARCODE_SHARE_KEY', _shareKey),
    );
  }
}

class BarcodeRevision {
  const BarcodeRevision({
    required this.createdAt,
    required this.updatedAt,
    this.brand = '',
    this.name = '',
    this.spec = '',
    this.ingredients = '',
  });

  final DateTime createdAt;
  final DateTime updatedAt;
  final String brand;
  final String name;
  final String spec;
  final String ingredients;

  Map<String, Object?> toJson() => {
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'brand': brand,
    'name': name,
    'spec': spec,
    'ingredients': ingredients,
  };

  factory BarcodeRevision.fromJson(Map<dynamic, dynamic> json) {
    final created = DateTime.tryParse('${json['createdAt'] ?? ''}');
    final updated = DateTime.tryParse('${json['updatedAt'] ?? ''}');
    return BarcodeRevision(
      createdAt: (created ?? updated ?? DateTime.now()).toUtc(),
      updatedAt: (updated ?? created ?? DateTime.now()).toUtc(),
      brand: '${json['brand'] ?? ''}',
      name: '${json['name'] ?? ''}',
      spec: '${json['spec'] ?? ''}',
      ingredients: '${json['ingredients'] ?? ''}',
    );
  }
}

enum ShareStatus { hit, miss, failed }

/// What `GET /v1/barcode-share` says. [ready] means this server speaks the
/// shared-barcode contract and a later build can turn the URL on.
class ShareConfig {
  const ShareConfig({
    required this.enabled,
    required this.contract,
    required this.version,
  });

  final bool enabled;
  final String contract;
  final int version;

  static const speaking = ShareConfig(
    enabled: true,
    contract: 'shared-barcodes',
    version: 1,
  );

  static const offline = ShareConfig(enabled: false, contract: '', version: 0);

  bool get ready => enabled && contract == 'shared-barcodes' && version >= 1;

  factory ShareConfig.fromJson(Map<dynamic, dynamic> json) {
    final version = json['version'];
    return ShareConfig(
      enabled: json['enabled'] == true,
      contract: '${json['contract'] ?? ''}',
      version: version is int ? version : int.tryParse('$version') ?? 0,
    );
  }
}

/// One consented product correction waiting for the share server.
/// Stored in settings, not in the care database.
class SharePending {
  const SharePending({
    required this.code,
    required this.brand,
    required this.name,
    required this.spec,
    required this.ingredients,
    required this.contributorId,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.attempts = 0,
    this.nextAttemptAt,
  });

  final String code;
  final String brand;
  final String name;
  final String spec;
  final String ingredients;
  final String contributorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;
  final int attempts;
  final DateTime? nextAttemptAt;

  SharePending retryAt(DateTime now) {
    final nextAttempts = attempts + 1;
    return SharePending(
      code: code,
      brand: brand,
      name: name,
      spec: spec,
      ingredients: ingredients,
      contributorId: contributorId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      imageUrl: imageUrl,
      attempts: nextAttempts,
      nextAttemptAt: now.toUtc().add(shareRetryDelay(nextAttempts)),
    );
  }

  BarcodeRecord toRecord() {
    return BarcodeRecord(
      code: code,
      found: true,
      brand: brand,
      name: name,
      quantity: spec,
      ingredients: ingredients,
      nutrients: const [],
      source: 'user',
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      contributorId: contributorId,
    );
  }

  Map<String, Object?> toJson() => {
    'code': code,
    'brand': brand,
    'name': name,
    'spec': spec,
    'ingredients': ingredients,
    'contributorId': contributorId,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'imageUrl': imageUrl,
    'attempts': attempts,
    'nextAttemptAt': nextAttemptAt?.toUtc().toIso8601String(),
  };

  factory SharePending.fromJson(Map<dynamic, dynamic> json) {
    final created = DateTime.tryParse('${json['createdAt'] ?? ''}');
    final updated = DateTime.tryParse('${json['updatedAt'] ?? ''}');
    final attempts = json['attempts'];
    return SharePending(
      code: '${json['code'] ?? ''}',
      brand: '${json['brand'] ?? ''}',
      name: '${json['name'] ?? ''}',
      spec: '${json['spec'] ?? ''}',
      ingredients: '${json['ingredients'] ?? ''}',
      contributorId: '${json['contributorId'] ?? ''}',
      createdAt: (created ?? updated ?? DateTime.now()).toUtc(),
      updatedAt: (updated ?? created ?? DateTime.now()).toUtc(),
      imageUrl: json['imageUrl'] is String ? json['imageUrl'] as String : null,
      attempts: attempts is int ? attempts : int.tryParse('$attempts') ?? 0,
      nextAttemptAt: DateTime.tryParse('${json['nextAttemptAt'] ?? ''}')
          ?.toUtc(),
    );
  }

  factory SharePending.fromRecord(BarcodeRecord record, DateTime now) {
    final when = now.toUtc();
    return SharePending(
      code: record.code,
      brand: record.brand,
      name: record.name,
      spec: record.quantity,
      ingredients: record.ingredients,
      contributorId: record.contributorId,
      createdAt: record.createdAt ?? when,
      updatedAt: record.updatedAt ?? when,
      imageUrl: record.imageUrl,
      nextAttemptAt: when.add(shareRetryDelay(1)),
    );
  }
}

/// 30s, 2min, 10min, then 1h. [attempts] is the count after a failed try.
Duration shareRetryDelay(int attempts) {
  if (attempts <= 1) return const Duration(seconds: 30);
  if (attempts == 2) return const Duration(minutes: 2);
  if (attempts == 3) return const Duration(minutes: 10);
  return const Duration(hours: 1);
}

String shareQueueKey(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return raw.trim();
  final trimmed = digits.replaceFirst(RegExp(r'^0+'), '');
  return trimmed.isEmpty ? '0' : trimmed;
}

/// The same barcode keeps only the newest queued correction. Cap at 40.
List<SharePending> enqueueShare(List<SharePending> queue, SharePending item) {
  final key = shareQueueKey(item.code);
  if (key.isEmpty) return queue;
  final next = <SharePending>[
    for (final row in queue)
      if (shareQueueKey(row.code) != key) row,
    item,
  ];
  if (next.length <= 40) return next;
  return next.sublist(next.length - 40);
}

List<SharePending> dropShare(List<SharePending> queue, String code) {
  final key = shareQueueKey(code);
  return [
    for (final row in queue)
      if (shareQueueKey(row.code) != key) row,
  ];
}

List<SharePending> decodeShareQueue(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return [
      for (final item in decoded)
        if (item is Map) SharePending.fromJson(item),
    ];
  } catch (_) {
    return [];
  }
}

String encodeShareQueue(List<SharePending> queue) {
  return jsonEncode([for (final item in queue) item.toJson()]);
}

class ShareAnswer {
  const ShareAnswer(this.status, [this.record]);

  final ShareStatus status;
  final BarcodeRecord? record;
}

/// Reads and writes the shared cat-food library.
abstract class BarcodeShareClient {
  Future<ShareAnswer> lookup(String code);
  Future<ShareAnswer> submit(BarcodeRecord record);

  /// Fakes speak the contract. The HTTP client reads `GET /v1/barcode-share`.
  Future<ShareConfig> config() async => ShareConfig.speaking;
}

class HttpBarcodeShareClient implements BarcodeShareClient {
  HttpBarcodeShareClient(this.share, {HttpClient? client})
    : _client = client ?? HttpClient();

  final BarcodeShare share;
  final HttpClient _client;

  @override
  Future<ShareConfig> config() async {
    if (!share.enabled) return ShareConfig.offline;
    final client = _client;
    try {
      final uri = Uri.parse('${share.baseUrl}/v1/barcode-share');
      final request = await client
          .openUrl('GET', uri)
          .timeout(const Duration(seconds: 4));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.userAgentHeader, barcodeUserAgent);
      final response = await request.close().timeout(
        const Duration(seconds: 4),
      );
      final text = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 4));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return ShareConfig.offline;
      }
      final decoded = jsonDecode(text);
      if (decoded is! Map) return ShareConfig.offline;
      return ShareConfig.fromJson(decoded);
    } catch (_) {
      return ShareConfig.offline;
    }
  }

  @override
  Future<ShareAnswer> lookup(String code) {
    return _send('GET', code);
  }

  @override
  Future<ShareAnswer> submit(BarcodeRecord record) {
    return _send(
      'PUT',
      record.code,
      body: {
        'barcode': record.code,
        'brand': record.brand,
        'name': record.name,
        'spec': record.quantity,
        'ingredients': record.ingredients,
        'imageUrl': _publicImage(record.imageUrl),
        'contributorId': record.contributorId,
        'createdAt': record.createdAt?.toUtc().toIso8601String(),
        'updatedAt': record.updatedAt?.toUtc().toIso8601String(),
      },
    );
  }

  Future<ShareAnswer> _send(
    String method,
    String code, {
    Map<String, Object?>? body,
  }) async {
    if (!share.enabled) return const ShareAnswer(ShareStatus.failed);
    final client = _client;
    try {
      final uri = Uri.parse(
        '${share.baseUrl}/v1/shared-barcodes/${Uri.encodeComponent(code.trim())}',
      );
      final request = await client
          .openUrl(method, uri)
          .timeout(const Duration(seconds: 4));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.userAgentHeader, barcodeUserAgent);
      if (share.key.isNotEmpty) {
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer ${share.key}',
        );
      }
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.add(utf8.encode(jsonEncode(body)));
      }
      final response = await request.close().timeout(
        const Duration(seconds: 4),
      );
      final text = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 404) {
        return const ShareAnswer(ShareStatus.miss);
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const ShareAnswer(ShareStatus.failed);
      }
      final decoded = jsonDecode(text);
      if (decoded is! Map) return const ShareAnswer(ShareStatus.failed);
      final record = _record(Map<String, Object?>.from(decoded), code);
      if (record == null) return const ShareAnswer(ShareStatus.miss);
      return ShareAnswer(ShareStatus.hit, record);
    } catch (_) {
      return const ShareAnswer(ShareStatus.failed);
    }
  }
}

String? _publicImage(String? raw) {
  final text = raw?.trim() ?? '';
  if (text.startsWith('https://') || text.startsWith('http://')) return text;
  return null;
}

BarcodeRecord? _record(Map<String, Object?> json, String fallbackCode) {
  final name = '${json['name'] ?? ''}'.trim();
  final brand = '${json['brand'] ?? ''}'.trim();
  if (name.isEmpty && brand.isEmpty) return null;
  final image = json['imageUrl'];
  return BarcodeRecord(
    code: '${json['barcode'] ?? fallbackCode}',
    found: true,
    brand: brand,
    name: name.isEmpty ? brand : name,
    quantity: '${json['spec'] ?? ''}',
    ingredients: '${json['ingredients'] ?? ''}',
    nutrients: const [],
    source: 'share',
    imageUrl: image is String && image.isNotEmpty ? image : null,
    createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}')?.toUtc(),
    updatedAt: DateTime.tryParse('${json['updatedAt'] ?? ''}')?.toUtc(),
    contributorId: '${json['contributorId'] ?? ''}',
  );
}
