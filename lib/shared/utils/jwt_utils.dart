import 'dart:convert';

class JwtUtils {
  /// 解析 JWT 並回傳 payload Map
  static Map<String, dynamic>? parseJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final payloadMap = json.decode(payload);
      if (payloadMap is! Map<String, dynamic>) return null;
      return payloadMap;
    } catch (_) {
      return null;
    }
  }

  /// 取得 exp 過期時間（秒）
  static int? getJwtExp(String token) {
    final payload = parseJwtPayload(token);
    if (payload == null) return null;
    final exp = payload['exp'];
    if (exp is int) return exp;
    if (exp is String) return int.tryParse(exp);
    return null;
  }

  /// 產生 mock JWT，可自訂 payload 與效期（秒）
  static String generateJwt({
    required Map<String, dynamic> payload,
    Duration validFor = const Duration(days: 1),
  }) {
    final header = {'alg': 'HS256', 'typ': 'JWT'};
    final exp = DateTime.now().millisecondsSinceEpoch ~/ 1000 + validFor.inSeconds;
    final fullPayload = Map<String, dynamic>.from(payload)..['exp'] = exp;

    String encode(Map<String, dynamic> data) =>
        base64Url.encode(utf8.encode(json.encode(data))).replaceAll('=', '');

    final encodedHeader = encode(header);
    final encodedPayload = encode(fullPayload);

    // 簽章可隨意填寫（mock用）
    const signature = 'mock_signature';

    return '$encodedHeader.$encodedPayload.$signature';
  }
}
