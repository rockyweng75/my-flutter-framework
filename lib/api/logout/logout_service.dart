import 'package:my_flutter_framework/api/logout/i_logout_service.dart';

class LogoutService implements ILogoutService {

  Future<bool> logout() async {
    // 清除登入憑證，例如 token
    // 這裡可以加入清除本地存儲的邏輯，例如 SharedPreferences 或 SecureStorage
    print('User logged out successfully.');
    return true;
  }
}