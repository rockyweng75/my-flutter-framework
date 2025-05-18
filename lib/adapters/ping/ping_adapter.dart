import 'dart:io';

import 'package:logger/logger.dart';
import 'package:my_flutter_framework/api/ping/i_ping_service.dart';
import 'package:my_flutter_framework/models/device_ping_result.dart';
import 'package:my_flutter_framework/models/ping_result.dart';

abstract class PingAdapter implements IPingService {

  PingAdapter();
  final Logger logger = Logger();
  String get pingCommand;
  String get pingArgs;
  String get pingArgs2;
  RegExp get pingRegex;

  Future<DevicePingResult> _ping(String ip, int index) async {
    bool online = false;
    double? ms = 0;
    try {
      // 修正參數順序，確保 pingArgs 在前，ip 在最後
      final args = [pingArgs, pingArgs2, ip].where((e) => e.isNotEmpty).toList();
      final result = await Process.run(pingCommand, args);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final match = pingRegex.firstMatch(output);
        if (match != null) {
          ms = double.tryParse(match.group(1)!);
          online = true;
        }
      } else {
        logger.e('Ping failed: \\nstdout: \\n${result.stdout}\\nstderr: \\n${result.stderr}');
        throw Exception('Ping failed: ${result.stderr}');
      }
    } catch (_) {
      online = false;
      ms = 0;
    }
    if (ms == null) {
      throw Exception('Ping failed: Unable to parse response time');
    }

    return DevicePingResult(
      ip: ip,
      name: 'Device-$index',
      ms: ms,
      online: online,
    );
  }

  @override
  Future<PingResult> ping(String ip) async {
    final result = await _ping(ip, 0);
    return PingResult(
      ip: result.ip,
      ms: result.ms,
      success: result.online,
    );
  }

  @override
  Future<List<DevicePingResult>> scanSubnet(String subnet) async {
    const batchSize = 20;
    List<DevicePingResult> results = [];
    List<Future<DevicePingResult>> batch = [];

    for (int i = 1; i <= 254; i++) {
      final ip = '$subnet$i';
      batch.add(_ping(ip, i));
      if (batch.length == batchSize || i == 254) {
        final batchResults = await Future.wait(batch);
        results.addAll(batchResults);
        batch.clear();
      }
    }
    return results;
  }
}
