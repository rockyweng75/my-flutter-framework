import 'dart:math';
import 'dart:async';
import 'package:my_flutter_framework/api/ping/i_ping_service.dart';
import 'package:my_flutter_framework/models/device_ping_result.dart';
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

  @override
  Future<List<DevicePingResult>> scanSubnet(String subnet) async {
    // 模擬掃描子網域的延遲
    await Future.delayed(const Duration(seconds: 2));
    // 隨機產生 254 個 IP 位址與 ping 結果
    return List.generate(254, (i) {
      final ip = '$subnet${i + 1}';
      return DevicePingResult(
        ip: ip,
        name: 'Device-${i + 1}',
        ms: (5 + i * 2).toDouble(),
        online: i % 3 != 0, // 每三個裝置中有一個離線
      );
    });
  }
}
