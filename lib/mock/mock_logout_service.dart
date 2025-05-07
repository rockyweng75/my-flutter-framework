import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_flutter_framework/api/logout/i_logout_service.dart';
import 'mock_http_client.dart';

class MockLogoutService implements ILogoutService {
  final MockHttpClient _mockHttpClient = MockHttpClient();

  @override
  Future<bool> logout() async {
    // 模擬 HTTP 請求
    final request = http.Request('POST', Uri.parse('/logout'));

    // 模擬回應 JSON
    const mockResponse = '{"success": true}';

    final response = await _mockHttpClient.send(request, customJsonString: mockResponse);

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      return data['success'] == true;
    } else {
      return false;
    }
  }
}