
import 'package:my_flutter_framework/api/http_client.dart';

import '../api/register/i_register_service.dart';

class MockRegisterService implements IRegisterService {
  MockRegisterService(this._httpClient);
  final HttpClient _httpClient;

  @override
  Future<void> register(String username, String email, String password) async {
    // 模擬註冊邏輯
    await Future.delayed(const Duration(milliseconds: 500));

    // 假設成功完成註冊
    return;
  }
}
