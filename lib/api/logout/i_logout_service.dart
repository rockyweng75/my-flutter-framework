

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/api/logout/logout_service.dart';
import 'package:my_flutter_framework/mock/mock_logout_service.dart';

final logoutServiceProvider = Provider<ILogoutService>((ref) {
  // 判斷是否為測試環境
  if (kDebugMode) {
    return MockLogoutService();
  } else {
    return LogoutService();
  }
});
abstract class ILogoutService {
  Future<bool> logout();
}

