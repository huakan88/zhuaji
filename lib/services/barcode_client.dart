import 'dart:convert';
import 'dart:io';

import '../domain/food/barcode_lookup.dart';

/// Identifies this app to Open Food Facts and the other public databases.
const barcodeUserAgent = 'PawPad/2.12 (com.maokangji.maokangji)';

/// Live lookup. Tests pass their own [BarcodeFetch] and never call this.
Future<BarcodeResponse> liveBarcodeFetch(Uri uri) async {
  final client = HttpClient();
  try {
    final request = await client
        .getUrl(uri)
        .timeout(const Duration(seconds: 8));
    request.headers.set(HttpHeaders.userAgentHeader, barcodeUserAgent);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final response = await request.close().timeout(const Duration(seconds: 8));
    final body = await response.transform(utf8.decoder).join();
    return BarcodeResponse(response.statusCode, body);
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
