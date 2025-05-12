import 'dart:async';
import 'package:my_flutter_framework/models/user.dart';
import 'i_login_service.dart';
class LoginService implements ILoginService {
  @override
  Future<User> login(String username, String password) async {
    throw UnimplementedError('LoginService.login() has not been implemented.');
  }
}
