import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/models/ping_result.dart';
import 'package:my_flutter_framework/pages/layout/main_layout_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:my_flutter_framework/api/ping/i_ping_service.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PingTestPage extends ConsumerStatefulWidget {
  const PingTestPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PingTestPageState();
}

class _PingTestPageState extends MainLayoutPage<PingTestPage> {
  final TextEditingController _ipController = TextEditingController(text: '8.8.8.8');
  final TextEditingController _countController = TextEditingController(text: '5');
  List<PingResult> _pingResults = [];
  bool _isLoading = false;
  String? _error;
  late final IPingService _pingService;

  @override
  void initState() {
    super.initState();
    // 這裡請根據實際後端 API baseUrl 設定
    _pingService = ref.read(pingServiceProvider);
  }

  Future<PingResult> _pingWeb(String ip) async {
    // Web: 呼叫後端 API 進行 ping
    return await _pingService.ping(ip);
  }

  Future<bool> _isEmulator() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return !androidInfo.isPhysicalDevice;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return !iosInfo.isPhysicalDevice;
    }
    return false;
  }

  Future<PingResult> _pingNative(String ip) async {
    if (await _isEmulator()) {
      return await _pingService.ping(ip);
    }
    try {
      final result = await Process.run(
        Platform.isWindows ? 'ping' : 'ping',
        Platform.isWindows
            ? ['-n', '1', ip]
            : ['-c', '1', ip],
      );
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        double? ms;
        if (Platform.isWindows) {
          // Windows: time=XXms
          final match = RegExp(r'time[=<]([0-9]+)ms').firstMatch(output);
          if (match != null) {
            ms = double.tryParse(match.group(1)!);
          }
        } else {
          // Unix: time=XX.X ms
          final match = RegExp(r'time=([0-9.]+) ms').firstMatch(output);
          if (match != null) {
            ms = double.tryParse(match.group(1)!);
          }
        }
        if (ms != null) {
          return PingResult(ip: ip, ms: ms, success: true);
        } else {
          // fallback: 解析不到回應時間
          return await _pingService.ping(ip);
        }
      } else {
        return await _pingService.ping(ip);
      }
    } catch (_) {
      return await _pingService.ping(ip);
    }
  }

  Future<void> _runPing() async {
    setState(() {
      _isLoading = true;
      _pingResults = [];
      _error = null;
    });
    final ip = _ipController.text.trim();
    final count = int.tryParse(_countController.text.trim()) ?? 5;
    try {
      List<PingResult> results = [];
      for (int i = 0; i < count; i++) {
        PingResult elapsed;
        if (kIsWeb) {
          elapsed = await _pingWeb(ip);
        } else {
          elapsed = await _pingNative(ip);
        }
        results.add(elapsed);
        await Future.delayed(const Duration(milliseconds: 300));
      }
      setState(() {
        _pingResults = results;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildChart() {
    if (_pingResults.isEmpty) {
      return const Text('尚未測試或無資料');
    }
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: _pingResults.asMap().entries.map((e) => FlSpot((e.key + 1).toDouble(), e.value.ms)).toList(),
              isCurved: false,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  // 僅顯示整數 x 標籤
                  if (value % 1 == 0) {
                    return Text(value.toInt().toString());
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }

  Widget _buildStats() {
    final valid = _pingResults.where((e) => e.success && e.ms > 0).toList();
    if (valid.isEmpty) {
      // return const Text('無有效 ping 資料');
      return const SizedBox.shrink();
    }
    final min = valid.map((e) => e.ms).reduce((a, b) => a < b ? a : b);
    final max = valid.map((e) => e.ms).reduce((a, b) => a > b ? a : b);
    final avg = valid.map((e) => e.ms).reduce((a, b) => a + b) / valid.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text('最小: ${min.toStringAsFixed(1)} ms', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 16),
          Text('最大: ${max.toStringAsFixed(1)} ms', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 16),
          Text('平均: ${avg.toStringAsFixed(1)} ms', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kIsWeb)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Web 端需後端 API 支援，否則無法取得真實 ping 值。',
                      style: TextStyle(color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ipController,
                  decoration: const InputDecoration(
                    labelText: 'IP 位址',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _countController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '次數',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : _runPing,
                child: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('開始'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_error != null)
            Text('錯誤: $_error', style: const TextStyle(color: Colors.red)),
          _buildChart(),
          _buildStats(),
        ],
      ),
    );
  }
}
