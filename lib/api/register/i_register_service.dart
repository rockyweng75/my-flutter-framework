

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/api/http_client.dart';
import 'package:my_flutter_framework/api/register/register_service.dart';
import 'package:my_flutter_framework/mock/mock_register_service.dart';

final registerServiceProvider = Provider<IRegisterService>((ref) {
  // 判斷是否為測試環境
  final httpClient = ref.watch(httpClientProvider);
  if (kDebugMode) {
    return MockRegisterService(httpClient);
  } else {
    return RegisterService(httpClient);
  }
});
abstract class IRegisterService {
  Future<void> register(String username, String email, String password);
}