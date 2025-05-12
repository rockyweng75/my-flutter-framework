import 'dart:convert';
import 'package:faker/faker.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_framework/models/user.dart';
import 'package:my_flutter_framework/shared/utils/jwt_utils.dart';
import '../api/login/i_login_service.dart';
import 'mock_http_client.dart';

class MockLoginService implements ILoginService {
  final MockHttpClient _mockHttpClient = MockHttpClient();

  final Map<String, String> _successUser = {
    'test': '1qaz@WSX',
    'admin': '1qaz@WSX',
  };

  @override
  Future<User> login(String username, String password) async {
    // 檢查使用者名稱和密碼是否正確
    if (!_successUser.containsKey(username) ||
        _successUser[username] != password) {
      throw Exception('使用者名稱或密碼錯誤');
    }

    // 產生效期為 1 天的 mock JWT
    final mockToken = JwtUtils.generateJwt(
      payload: {
        'username': username,
        'exp': DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000,
      }
    );

    // 模擬 HTTP 請求
    final request = http.Request('POST', Uri.parse('/login'))
      ..body = jsonEncode({'username': username, 'password': password});

    // 模擬回應 JSON
    const mockResponse = '{"username": "test", "token": "mock_token_12345"}';

    final response = await _mockHttpClient.send(
      request,
      customJsonString: mockResponse,
    );

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      final faker = Faker();

      return User(
        account: data['username'],
        name: data['username'],
        token: mockToken,
        email: faker.internet.email(),
        jobTitle: faker.job.title(),
      );
    } else {
      throw Exception('模擬登入失敗: 使用者名稱或密碼錯誤');
    }
  }
}
