import 'dart:async';

import 'i_login_service.dart';
import 'login_model.dart';



class LoginService implements ILoginService {
  @override
  Future<LoginModel> login(String username, String password) async {
    // 真實的 API 請求邏輯可以在這裡實現
    await Future.delayed(const Duration(seconds: 2));

    // 假設成功返回一個 LoginModel
    return LoginModel(username: username, token: 'real_token_12345');
  }
}
