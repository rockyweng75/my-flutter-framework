import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/login/i_login_service.dart';
import '../api/login/login_model.dart';
import 'mock_http_client.dart';

class MockLoginService implements ILoginService {
  final MockHttpClient _mockHttpClient = MockHttpClient();

  @override
  Future<LoginModel> login(String username, String password) async {
    // 模擬 HTTP 請求
    final request = http.Request('POST', Uri.parse('/login'))
      ..body = jsonEncode({'username': username, 'password': password});

    // 模擬回應 JSON
    const mockResponse = '{"username": "test", "token": "mock_token_12345"}';

    final response = await _mockHttpClient.send(request, customJsonString: mockResponse);

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      return LoginModel(
        username: data['username'],
        token: data['token'],
      );
    } else {
      throw Exception('模擬登入失敗: 使用者名稱或密碼錯誤');
    }
  }
}