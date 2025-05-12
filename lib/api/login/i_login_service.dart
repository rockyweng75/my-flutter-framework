import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/api/login/login_service.dart';
import 'package:my_flutter_framework/mock/mock_login_service.dart';
import 'package:my_flutter_framework/models/user.dart';

final loginServiceProvider = Provider<ILoginService>((ref) {
  // 判斷是否為測試環境
  if (kDebugMode) {
    return MockLoginService();
  } else {
    return LoginService();
  }
});
abstract class ILoginService {
  Future<User> login(String username, String password);
}

