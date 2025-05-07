import 'package:my_flutter_framework/api/http_client.dart';
import 'i_register_service.dart';

class RegisterService implements IRegisterService {

  RegisterService(this._httpClient);
  final HttpClient _httpClient;
  @override
  Future<void> register(String username, String email, String password) async {
    // 真實的 API 請求邏輯可以在這裡實現
    await Future.delayed(const Duration(seconds: 2));

    // 假設成功完成註冊
    return;
  }
}