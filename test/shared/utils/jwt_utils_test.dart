import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/shared/utils/jwt_utils.dart';
import 'dart:convert';

String generateTestJwt({required int exp, Map<String, dynamic>? extraPayload}) {
  final header = base64Url.encode(
    utf8.encode(json.encode({'alg': 'HS256', 'typ': 'JWT'})),
  );
  final payloadMap = {'exp': exp, ...?extraPayload};
  final payload = base64Url.encode(utf8.encode(json.encode(payloadMap)));
  // signature can be anything for test
  return '$header.$payload.signature';
}

void main() {
  group('JwtUtils', () {
    test('parseJwtPayload 正常解析 payload', () {
      final exp = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;
      final token = generateTestJwt(exp: exp, extraPayload: {'sub': 'user1'});
      final payload = JwtUtils.parseJwtPayload(token);
      expect(payload, isNotNull);
      expect(payload!['exp'], exp);
      expect(payload['sub'], 'user1');
    });

    test('getJwtExp 正常取得 exp', () {
      final exp = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 7200;
      final token = generateTestJwt(exp: exp);
      final result = JwtUtils.getJwtExp(token);
      expect(result, exp);
    });

    test('parseJwtPayload 回傳 null (格式錯誤)', () {
      final token = 'invalid.token';
      final payload = JwtUtils.parseJwtPayload(token);
      expect(payload, isNull);
    });

    test('getJwtExp 回傳 null (無 exp)', () {
      final header = base64Url.encode(
        utf8.encode(json.encode({'alg': 'HS256', 'typ': 'JWT'})),
      );
      final payload = base64Url.encode(
        utf8.encode(json.encode({'sub': 'user2'})),
      );
      final token = '$header.$payload.signature';
      final result = JwtUtils.getJwtExp(token);
      expect(result, isNull);
    });

    test('generateJwt 可產生正確 payload 並帶 exp', () {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final token = JwtUtils.generateJwt(
        payload: {'sub': 'user3'},
        validFor: const Duration(hours: 2),
      );
      final payload = JwtUtils.parseJwtPayload(token);
      expect(payload, isNotNull);
      expect(payload!['sub'], 'user3');
      expect(
        payload['exp'],
        greaterThanOrEqualTo(now + 2 * 3600 - 5),
      ); // exp 約略等於 now+2hr
      expect(payload['exp'], lessThanOrEqualTo(now + 2 * 3600 + 5));

      // 測試過期時間
      final expiredToken = JwtUtils.generateJwt(
        payload: {'sub': 'user4'},
        validFor: const Duration(seconds: -1),
      );
      final expiredPayload = JwtUtils.parseJwtPayload(expiredToken);
      expect(expiredPayload, isNotNull);
      expect(expiredPayload!['sub'], 'user4');
      expect(
        JwtUtils.getJwtExp(expiredToken),
        lessThan(now),
      ); // exp 應小於現在時間
      expect(
        JwtUtils.getJwtExp(expiredToken),
        greaterThanOrEqualTo(now - 5),
      ); // exp 約略等於現在時間
      expect(
        JwtUtils.getJwtExp(expiredToken),
        lessThanOrEqualTo(now + 5),
      ); // exp 約略等於現在時間
      
    });
  });
}
