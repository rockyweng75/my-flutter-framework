import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_flutter_framework/adapters/ping/ping_adapter.dart';
import 'package:my_flutter_framework/models/ping_result.dart';

class TestPingAdapter extends PingAdapter {
  @override
  String get pingCommand => 'echo'; // 用 echo 模擬，不實際發送 ping
  @override
  String get pingArgs => '';
  @override
  String get pingArgs2 => '';
  @override
  RegExp get pingRegex => RegExp(r'(\d+)');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('PingAdapter Integration', () {
    late TestPingAdapter adapter;
    setUp(() {
      adapter = TestPingAdapter();
    });

    testWidgets('ping() returns PingResult', (tester) async {
      final result = await adapter.ping('127.0.0.1');
      expect(result, isA<PingResult>());
      expect(result.ip, '127.0.0.1');
    });

    testWidgets('_ping() returns PingResult', (tester) async {
      final result = await adapter.ping('127.0.0.1');
      expect(result, isA<PingResult>());
      expect(result.ip, '127.0.0.1');
    });
  });
}
