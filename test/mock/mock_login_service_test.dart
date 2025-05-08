import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/api/login/login_model.dart';
import 'package:my_flutter_framework/mock/mock_login_service.dart';

void main() {
  group('MockLoginService', () {
    late MockLoginService mockLoginService;

    setUp(() {
      mockLoginService = MockLoginService();
    });

    test('login should return a valid LoginModel', () async {
      final username = 'test';
      final password = '1qaz@WSX';

      final result = await mockLoginService.login(username, password);

      expect(result, isA<LoginModel>());
      expect(result.username, 'test');
      expect(result.token, 'mock_token_12345');
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