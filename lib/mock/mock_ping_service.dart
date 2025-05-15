import 'dart:math';
import 'dart:async';
import 'package:my_flutter_framework/api/ping/i_ping_service.dart';
import 'package:my_flutter_framework/models/ping_result.dart';

class MockPingService implements IPingService {
  final Random _random = Random();

  @override
  Future<PingResult> ping(String ip) async {
    // 模擬網路延遲 100~300ms
    final ms = 100 + _random.nextInt(200);
    await Future.delayed(Duration(milliseconds: ms));
    // 80% 機率成功，20% 機率失敗
    if (_random.nextDouble() < 0.8) {
      return PingResult(ip: ip, ms: ms.toDouble(), success: true);
    } else {
      return PingResult(ip: ip, ms: 0, success: false);
    }
  }
}
