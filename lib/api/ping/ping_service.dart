import 'package:http/http.dart' as http;
import 'package:my_flutter_framework/api/http_client.dart';
import 'package:my_flutter_framework/api/ping/i_ping_service.dart';
import 'package:my_flutter_framework/models/device_ping_result.dart';
import 'dart:convert';
import 'package:my_flutter_framework/models/ping_result.dart';

class PingService implements IPingService {
  final HttpClient httpClient;
  PingService({required this.httpClient});

  /// 呼叫後端 API 進行 ping，回傳 PingResult，失敗則回傳 ms=0, success=false
  Future<PingResult> ping(String ip) async {
    final url = Uri.parse('${httpClient.baseUrl}/ping?ip=$ip');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map) {
          return PingResult.fromJson(Map<String, dynamic>.from(data));
        }
      }
      return PingResult(ip: ip, ms: 0, success: false);
    } catch (_) {
      return PingResult(ip: ip, ms: 0, success: false);
    }
  }

  /// 掃描整個子網域，回傳裝置清單與 ping 結果
  @override
  Future<List<DevicePingResult>> scanSubnet(String subnet) async {
    final url = Uri.parse('${httpClient.baseUrl}/ping/scan?subnet=$subnet');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.map((e) => DevicePingResult.fromJson(Map<String, dynamic>.from(e))).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
