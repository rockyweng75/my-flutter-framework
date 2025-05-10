import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/api/notification/i_notification_service.dart';
import 'package:my_flutter_framework/pages/swipe_page_demo.dart';

import 'message_box_page_test.dart';

void main() {
  group('SwipePageDemo', () {
    testWidgets('displays the correct initial page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationServiceProvider.overrideWithValue(
              TestNotificationService(),
            ),
          ],
          child: MaterialApp(home: SwipePageDemo()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the initial page is Page 2 (green)
      expect(find.text('Page 2'), findsOneWidget);
      expect(find.text('Page 1'), findsNothing);
      expect(find.text('Page 3'), findsNothing);
    });

    testWidgets('can swipe to the next and previous pages', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationServiceProvider.overrideWithValue(
              TestNotificationService(),
            ),
          ],
          child: MaterialApp(home: SwipePageDemo()),
        ),
      );

      // 預設只有三頁，先滑到第三頁
      await tester.drag(find.byType(PageView), const Offset(-800, 0));
      await tester.pumpAndSettle();
      expect(find.text('Page 3'), findsOneWidget);

      // 往回滑到第二頁
      await tester.drag(find.byType(PageView), const Offset(800, 0));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Page 2'), findsOneWidget);

      
    });

    testWidgets('can load more pages when swiping to the end', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationServiceProvider.overrideWithValue(
              TestNotificationService(),
            ),
          ],
          child: MaterialApp(home: SwipePageDemo()),
        ),
      );

      // 預設只有三頁，先滑到第三頁
      await tester.drag(find.byType(PageView), const Offset(-800, 0));
      await tester.pumpAndSettle();
      expect(find.text('Page 3'), findsOneWidget);

      // 再滑一次，觸發 loadMore，會顯示 loading page
      await tester.drag(find.byType(PageView), const Offset(-800, 0));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 等待 loading 結束
      await tester.pump(const Duration(seconds: 2));
      // 驗證新頁面已載入
      expect(find.text('Page 4'), findsOneWidget);
    });
  });
}
