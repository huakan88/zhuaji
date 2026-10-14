import 'dart:convert';

import 'package:crypto/crypto.dart';

String signJwt(
  Map<String, Object?> claims,
  String secret, {
  Duration ttl = const Duration(days: 30),
}) {
  final header = _b64(jsonEncode({'alg': 'HS256', 'typ': 'JWT'}));
  final body = _b64(
    jsonEncode({
      ...claims,
      'exp': DateTime.now().toUtc().add(ttl).millisecondsSinceEpoch ~/ 1000,
    }),
  );
  final sig = _b64(
    Hmac(
      sha256,
      utf8.encode(secret),
    ).convert(utf8.encode('$header.$body')).bytes,
  );
  return '$header.$body.$sig';
}

Map<String, Object?>? verifyJwt(String token, String secret) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  final expected = _b64(
    Hmac(
      sha256,
      utf8.encode(secret),
    ).convert(utf8.encode('${parts[0]}.${parts[1]}')).bytes,
  );
  if (expected != parts[2]) return null;
  final claims = jsonDecode(_unb64(parts[1]));
  if (claims is! Map) return null;
  final exp = claims['exp'];
  if (exp is! int) return null;
  final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  if (exp < now) return null;
  return Map<String, Object?>.from(claims);
}

String _b64(Object value) {
  final bytes = value is List<int> ? value : utf8.encode(value as String);
  return base64Url.encode(bytes).replaceAll('=', '');
}

String _unb64(String value) {
  final pad = value.length % 4 == 0 ? '' : '=' * (4 - value.length % 4);
  return utf8.decode(base64Url.decode('$value$pad'));
}
