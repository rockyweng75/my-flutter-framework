import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/api/ping/i_ping_service.dart';
import 'package:my_flutter_framework/models/device_ping_result.dart';
import 'package:my_flutter_framework/pages/layout/main_layout_page.dart';
import 'package:flutter/foundation.dart';
import 'package:my_flutter_framework/shared/utils/transaction_manager.dart';
import 'dart:io';
import 'package:my_flutter_framework/styles/app_color.dart';

class PingDevicesPage extends ConsumerStatefulWidget {
  const PingDevicesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PingDevicesPageState();
}

class _PingDevicesPageState extends MainLayoutPage<PingDevicesPage> {
  final TextEditingController _subnetController = TextEditingController(
    text: '192.168.1.',
  );
  bool _isLoading = false;
  String? _error;
  List<DevicePingResult> _results = [];
  late final IPingService _pingService;
  int _selectedIndex = -1;
  final ScrollController _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pingService = ref.read(pingServiceProvider);
  }

  Future<void> _scanByWeb() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _results = [];
    });
    final subnet = _subnetController.text.trim();

    await TransactionManager(context).execute(() async {
      _results = await _pingService.scanSubnet(subnet);
      if (_results.isEmpty) {
        _error = '掃描結果為空，請檢查網路或後端 API';
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _scanByNative() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _results = [];
    });
    final subnet = _subnetController.text.trim();
    await TransactionManager(context).execute(() async {
      try {
        if (Theme.of(context).platform == TargetPlatform.android ||
            Theme.of(context).platform == TargetPlatform.iOS) {
          // 並行掃描區網裝置
          const batchSize = 20;
          List<DevicePingResult> results = [];
          List<Future<DevicePingResult>> batch = [];
          Future<DevicePingResult> pingIp(String ip, int i) async {
            bool online = false;
            double ms = 0;
            try {
              final result = await Process.run('ping', ['-c', '1', ip]);
              if (result.exitCode == 0) {
                final output = result.stdout.toString();
                final match = RegExp(r'time=([0-9.]+) ms').firstMatch(output);
                if (match != null) {
                  ms = double.tryParse(match.group(1)!) ?? 0;
                  online = true;
                }
              }
            } catch (_) {
              online = false;
              ms = 0;
            }
            return DevicePingResult(
              ip: ip,
              name: 'Device-$i',
              ms: ms,
              online: online,
            );
          }
          for (int i = 1; i <= 254; i++) {
            final ip = '$subnet$i';
            batch.add(pingIp(ip, i));
            if (batch.length == batchSize || i == 254) {
              final batchResults = await Future.wait(batch);
              results.addAll(batchResults);
              batch.clear();
            }
          }
          _results = results;
        } else {
          _results = await _pingService.scanSubnet(subnet);
          if (_results.isEmpty) {
            _error = '掃描結果為空，請檢查網路或後端 API';
          }
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        _error = e.toString();
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _scanDevices() async {
    if (kIsWeb) {
      await _scanByWeb();
    } else {
      await _scanByNative();
    }
  }

  Widget _buildByWeb() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Web 端需後端 API 支援，否則無法取得真實區網裝置掃描。',
                  style: TextStyle(color: Colors.orange[800]),
                ),
              ),
            ],
          ),
        ),
        _buildCommonContent(),
      ],
    );
  }

  Widget _buildByNative() {
    final isSupported = Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux ||
        Theme.of(context).platform == TargetPlatform.macOS;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isSupported)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '此平台暫不支援區網裝置掃描（需支援 dart:io）。',
                    style: TextStyle(color: Colors.orange[800]),
                  ),
                ),
              ],
            ),
          ),
        _buildCommonContent(),
      ],
    );
  }

  Widget _buildCommonContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _subnetController,
          decoration: const InputDecoration(
            labelText: '子網路 (如 192.168.1.)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _scanDevices,
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('掃描裝置'),
            ),
            if (_error != null) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '錯誤: $_error',
                  style: const TextStyle(color: Colors.red),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 350,
          child:
              _results.isEmpty
                  ? const Text('尚未掃描或無裝置')
                  : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final r = _results[index];
                      return Card(
                        color: r.online ? Colors.green[50] : Colors.red[50],
                        child: ListTile(
                          selected: index == _selectedIndex,
                          selectedTileColor: Colors.blue.withOpacity(0.15),
                          leading: Icon(
                            r.online ? Icons.check_circle : Icons.cancel,
                            color: r.online ? Colors.green : Colors.red,
                          ),
                          title: Text(r.ip),
                          subtitle: Text(r.name),
                          trailing: Text(
                            r.online ? '${r.ms.toStringAsFixed(1)} ms' : '離線',
                            style: TextStyle(
                              color: r.online ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                    controller: _listScrollController,
                  ),
        ),
        const SizedBox(height: 16),
        _buildStatsInfo(),
        const SizedBox(height: 16),
        if (_results.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _focusPrev();
                },
                child: const Text('上一筆'),
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                onPressed: () {
                  _focusNext();
                },
                child: const Text('下一筆'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStatsInfo() {
    if (_results.isEmpty) return const SizedBox.shrink();
    final online = _results.where((e) => e.online).toList();
    final offline = _results.where((e) => !e.online).toList();
    final onlineCount = online.length;
    final offlineCount = offline.length;
    double? minMs, maxMs, avgMs;
    String? maxIp;
    if (online.isNotEmpty) {
      minMs = online.map((e) => e.ms).reduce((a, b) => a < b ? a : b);
      maxMs = online.map((e) => e.ms).reduce((a, b) => a > b ? a : b);
      avgMs = online.map((e) => e.ms).reduce((a, b) => a + b) / online.length;
      final maxDevice = online.firstWhere(
        (e) => e.ms == maxMs,
        orElse: () => online.first,
      );
      maxIp = maxDevice.ip;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onlineColor = isDark ? AppColor.successLight : AppColor.success;
    final offlineColor = isDark ? AppColor.dangerLight : AppColor.danger;
    final statTextColor = isDark ? Colors.white : AppColor.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '在線: $onlineCount',
              style: TextStyle(fontSize: 14, color: onlineColor),
            ),
            const SizedBox(width: 16),
            Text(
              '離線: $offlineCount',
              style: TextStyle(fontSize: 14, color: offlineColor),
            ),
          ],
        ),
        if (online.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                Text(
                  '最小: ${minMs!.toStringAsFixed(1)} ms',
                  style: TextStyle(fontSize: 14, color: statTextColor),
                ),
                const SizedBox(width: 16),
                Text(
                  '最大: ${maxMs!.toStringAsFixed(1)} ms',
                  style: TextStyle(fontSize: 14, color: statTextColor),
                ),
                const SizedBox(width: 16),
                Text(
                  '平均: ${avgMs!.toStringAsFixed(1)} ms',
                  style: TextStyle(fontSize: 14, color: statTextColor),
                ),
              ],
            ),
          ),
        if (online.isNotEmpty && maxIp != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '最大 ping IP: $maxIp',
              style: TextStyle(fontSize: 13, color: statTextColor),
            ),
          ),
      ],
    );
  }

  void _focusIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // 自動滾動到該項目
    _listScrollController.animateTo(
      index * 72.0, // 預估每個 Card 高度
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _focusPrev() {
    final online =
        _results
            .asMap()
            .entries
            .where((e) => e.value.online)
            .map((e) => e.key)
            .toList();
    if (online.isEmpty) return;
    int current = online.indexWhere((i) => i == _selectedIndex);
    if (current > 0) {
      _focusIndex(online[current - 1]);
    }
  }

  void _focusNext() {
    final online =
        _results
            .asMap()
            .entries
            .where((e) => e.value.online)
            .map((e) => e.key)
            .toList();
    if (online.isEmpty) return;
    int current = online.indexWhere((i) => i == _selectedIndex);
    if (current == -1) {
      _focusIndex(online.first);
    } else if (current < online.length - 1) {
      _focusIndex(online[current + 1]);
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    if (kIsWeb) {
      return Padding(padding: const EdgeInsets.all(16.0), child: _buildByWeb());
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildByNative(),
      );
    }
  }
}
