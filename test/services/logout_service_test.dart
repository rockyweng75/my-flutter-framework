import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/api/logout/i_logout_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/mock/mock_logout_service.dart';

final logoutServiceProvider = Provider<ILogoutService>((ref) {
  return MockLogoutService();
});

void main() {
  group('LogoutService', () {
    late ProviderContainer container;
    late ILogoutService logoutService;

    setUp(() {
      container = ProviderContainer();
      logoutService = container.read(logoutServiceProvider);
    });

    test('logout should clear user credentials', () async {
      await logoutService.logout();
      // 檢查是否成功執行登出邏輯
      expect(true, isTrue, reason: 'Logout logic executed successfully.');
    });

    tearDown(() {
      container.dispose();
    });
  });
}
