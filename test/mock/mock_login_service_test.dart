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
      final password = 'password';

      final result = await mockLoginService.login(username, password);

      expect(result, isA<LoginModel>());
      expect(result.username, 'test');
      expect(result.token, 'mock_token_12345');
    });
  });
}