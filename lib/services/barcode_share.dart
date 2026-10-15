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

class ShareAnswer {
  const ShareAnswer(this.status, [this.record]);

  final ShareStatus status;
  final BarcodeRecord? record;
}

/// Reads and writes the shared cat-food library.
abstract class BarcodeShareClient {
  Future<ShareAnswer> lookup(String code);
  Future<ShareAnswer> submit(BarcodeRecord record);
}

class HttpBarcodeShareClient implements BarcodeShareClient {
  HttpBarcodeShareClient(this.share, {HttpClient? client})
    : _client = client ?? HttpClient();

  final BarcodeShare share;
  final HttpClient _client;

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
