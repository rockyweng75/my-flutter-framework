import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/adapters/ping/android_ping_adapter.dart';
import 'package:my_flutter_framework/adapters/ping/windows_ping_adapter.dart';
import 'package:my_flutter_framework/api/http_client.dart';
import 'package:my_flutter_framework/api/ping/ping_service.dart';
import 'package:my_flutter_framework/mock/mock_ping_service.dart';
import 'package:my_flutter_framework/models/device_ping_result.dart';
import 'package:my_flutter_framework/models/ping_result.dart';

final pingServiceProvider = Provider<IPingService>((ref) {
  // 若為 web 或不支援 dart:io，強制使用 Mock
  if (kIsWeb) {
    if (kDebugMode) {
      return MockPingService();
    } else {
      final HttpClient httpClient = ref.watch(httpClientProvider);
      return PingService(httpClient: httpClient);
    }
  }
  try {
    final test = Platform.operatingSystem;
    if(test == 'windows' ) {
      return WindowsPingAdapter();
    } else {
      return AndroidPingAdapter();
    }
  } catch (_) {
    return MockPingService();
  }
});

abstract class IPingService {
  /// 呼叫後端 API 進行 ping，回傳延遲（毫秒），失敗則回傳 0
  Future<PingResult> ping(String ip);

  Future<List<DevicePingResult>> scanSubnet(String subnet);
}
