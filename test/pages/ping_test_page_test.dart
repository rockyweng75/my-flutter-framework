import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_framework/api/notification/i_notification_service.dart';
import 'package:my_flutter_framework/api/ping/i_ping_service.dart';
import 'package:my_flutter_framework/mock/mock_ping_service.dart';
import 'package:my_flutter_framework/pages/ping/ping_test_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_flutter_framework/models/ping_result.dart';
import 'dart:math';

import 'message_box_page_test.dart';

class FastMockPingService extends MockPingService {
  @override
  Future<PingResult> ping(String ip) async {
    // 減少延遲，讓測試更快
    final ms = 10 + (Random().nextInt(10));
    await Future.delayed(Duration(milliseconds: ms));
    return PingResult(ip: ip, ms: ms.toDouble(), success: true);
  }
}

void main() {
  testWidgets('PingTestPage UI smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationServiceProvider.overrideWithValue(
            TestNotificationService(),
          ),
          pingServiceProvider.overrideWithValue(
            MockPingService(),
          ),
        ],
        child: MaterialApp(home: PingTestPage()),
      ),
    );

    await tester.pumpAndSettle();

    // 檢查 IP 輸入框
    expect(find.widgetWithText(TextField, 'IP 位址'), findsOneWidget);
    // 檢查次數輸入框
    expect(find.widgetWithText(TextField, '次數'), findsOneWidget);
    // 檢查開始按鈕
    expect(find.widgetWithText(ElevatedButton, '開始'), findsOneWidget);
  });

  testWidgets('PingTestPage ping 功能測試', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationServiceProvider.overrideWithValue(
            TestNotificationService(),
          ),
          pingServiceProvider.overrideWithValue(
            FastMockPingService(),
          ),
        ],
        child: MaterialApp(home: PingTestPage()),
      ),
    );
    await tester.pumpAndSettle();

    // 輸入次數 5
    await tester.enterText(find.widgetWithText(TextField, '次數'), '5');
    await tester.pump();

    // 點擊開始
    await tester.tap(find.byKey(const Key('ping_start_button')));
    await tester.pump(); // 讓 onPressed callback 執行
    // 最多等 5 秒，每 500ms 檢查一次是否有統計資訊
    // bool found = false;
    // for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 1000000));
      // if (find.textContaining('最小:').evaluate().isNotEmpty) {
      //   found = true;
      //   // break;
      // }
    // }
    // expect(found, isTrue, reason: '未找到統計資訊，可能 ping 尚未完成或按鈕未被正確觸發');

    // 應該會顯示統計資訊
    expect(find.textContaining('最小:'), findsOneWidget);
    expect(find.textContaining('最大:'), findsOneWidget);
    expect(find.textContaining('平均:'), findsOneWidget);
    // 應該會有圖表
    expect(find.byType(LineChart), findsOneWidget);
  });
}
