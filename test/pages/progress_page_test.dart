import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/api/notification/i_notification_service.dart';
import 'package:my_flutter_framework/pages/progress/_page.dart';

import 'message_box_page_test.dart';

void main() {
  testWidgets('ProgressPage 顯示進度遮罩與進度文字', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationServiceProvider.overrideWithValue(
            TestNotificationService(),
          ),
        ],
        child: MaterialApp(home: ProgressPage()),
      ),
    );
    // 初始進度應為 0%
    expect(find.text('目前進度：0%'), findsOneWidget);
    expect(find.byType(ProgressPage), findsOneWidget);
    expect(find.byType(Column), findsOneWidget);
    // 遮罩應該存在
    expect(find.byType(ProgressPage), findsOneWidget);
    expect(find.byType(Container), findsWidgets);

    // 模擬 1 秒後進度變化
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('目前進度：10%'), findsOneWidget);

    // debug: 輸出所有 Icon 資訊
    final iconFinder = find.byType(Icon);
    print('Icon widgets found: \\${iconFinder.evaluate().length}');
    for (final e in iconFinder.evaluate()) {
      final icon = e.widget as Icon;
      print('Icon: \\${icon.icon}');
    }
    expect(find.byIcon(Icons.hourglass_bottom), findsOneWidget);

    // 模擬到 100%
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('目前進度：100%'), findsOneWidget);
  });
}
