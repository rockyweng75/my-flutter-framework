import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/pages/layout/main_layout_page.dart';

class TransrouteTestPage extends ConsumerStatefulWidget {
  const TransrouteTestPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TransrouteTestPageState();
}

class _TransrouteTestPageState extends MainLayoutPage<TransrouteTestPage> {
  final TextEditingController _ipController = TextEditingController(text: '8.8.8.8');
  bool _isLoading = false;
  String? _error;
  List<_TransrouteHop> _hops = [];

  Future<void> _runTransroute() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _hops = [];
    });
    final ip = _ipController.text.trim();
    try {
      // TODO: 實作 transroute/traceroute 呼叫，這裡用假資料
      await Future.delayed(const Duration(seconds: 2));
      _hops = List.generate(8, (i) => _TransrouteHop(
        hop: i + 1,
        ip: '192.168.1.${i + 1}',
        ms: 10.0 + i * 8,
        name: 'Node-${i + 1}',
      ));
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _ipController,
            decoration: const InputDecoration(
              labelText: '目標 IP 或網域',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : _runTransroute,
                child: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('開始測試'),
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
              ]
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _hops.isEmpty
                ? const Text('尚未測試或無資料')
                : ListView.separated(
                    itemCount: _hops.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final hop = _hops[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${hop.hop}')),
                        title: Text(hop.ip),
                        subtitle: Text(hop.name),
                        trailing: Text('${hop.ms.toStringAsFixed(1)} ms'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TransrouteHop {
  final int hop;
  final String ip;
  final double ms;
  final String name;
  _TransrouteHop({required this.hop, required this.ip, required this.ms, required this.name});
}
