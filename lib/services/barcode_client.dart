import 'dart:convert';
import 'dart:io';

import '../domain/food/barcode_lookup.dart';

/// Identifies this app to Open Food Facts and the other public databases.
const barcodeUserAgent = 'PawPad/2.14 (com.maokangji.maokangji)';

const _juheKey = String.fromEnvironment('JUHE_BARCODE_KEY');
const _aliyunAppCode = String.fromEnvironment('ALIYUN_BARCODE_APPCODE');
const _topthinkToken = String.fromEnvironment('TOPTHINK_BARCODE_TOKEN');
const _goUpcKey = String.fromEnvironment('GO_UPC_KEY');
const _eanSearchToken = String.fromEnvironment('EAN_SEARCH_TOKEN');

/// Compiled `--dart-define` values, overridden by a non-empty environment variable.
BarcodeKeys barcodeKeysFromEnvironment() {
  String pick(String name, String compiled) {
    final env = Platform.environment[name]?.trim() ?? '';
    if (env.isNotEmpty) return env;
    return compiled.trim();
  }

  return BarcodeKeys(
    juhe: pick('JUHE_BARCODE_KEY', _juheKey),
    aliyunAppCode: pick('ALIYUN_BARCODE_APPCODE', _aliyunAppCode),
    topthink: pick('TOPTHINK_BARCODE_TOKEN', _topthinkToken),
    goUpc: pick('GO_UPC_KEY', _goUpcKey),
    eanSearch: pick('EAN_SEARCH_TOKEN', _eanSearchToken),
  );
}

/// Live lookup. Tests pass their own [BarcodeFetch] and never call this.
Future<BarcodeResponse> liveBarcodeFetch(BarcodeCall call) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(call.uri).timeout(call.timeout);
    request.headers.set(HttpHeaders.userAgentHeader, barcodeUserAgent);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    call.headers.forEach(request.headers.set);
    final response = await request.close().timeout(call.timeout);
    final body = await response
        .transform(utf8.decoder)
        .join()
        .timeout(call.timeout);
    return BarcodeResponse(response.statusCode, body);
  } catch (_) {
    return const BarcodeResponse(0, '');
  } finally {
    client.close(force: true);
  }
}

BarcodeFetch defaultBarcodeFetch() {
  if (Platform.environment['FLUTTER_TEST'] == 'true') {
    return (_) async => const BarcodeResponse(0, '');
  }
  return liveBarcodeFetch;
}
