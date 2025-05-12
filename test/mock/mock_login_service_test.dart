import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/mock/mock_login_service.dart';
import 'package:my_flutter_framework/models/user.dart';
import 'package:my_flutter_framework/shared/utils/jwt_utils.dart';

void main() {
  group('MockLoginService', () {
    late MockLoginService mockLoginService;

    setUp(() {
      mockLoginService = MockLoginService();
    });

    test('login should return a valid User', () async {
      final username = 'test';
      final password = '1qaz@WSX';

      final result = await mockLoginService.login(username, password);

      expect(result, isA<User>());
      expect(result.account, 'test');
      final map = JwtUtils.parseJwtPayload(result.token);
      expect(map, isNotNull);
      expect(map!['username'], 'test');
      expect(map['exp'], isNotNull);
    });

    test('login should throw an exception for incorrect password', () async {
      final username = 'test';
      final password = 'wrong_password';

      expect(
        () async => await mockLoginService.login(username, password),
        throwsException,
      );
    });

    test('login should throw an exception for non-existent username', () async {
      final username = 'non_existent_user';
      final password = '1qaz@WSX';

      expect(
        () async => await mockLoginService.login(username, password),
        throwsException,
      );
    });
  });
}