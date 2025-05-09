import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/api/notification/i_notification_service.dart';
import 'package:my_flutter_framework/router/app_router.dart';
import 'package:my_flutter_framework/shared/components/buttons/drag_confirm_button.dart';

import '../message_box_page_test.dart';

void main() {
  testWidgets('DragConfirmButtonDemoPage displays DragConfirmButton', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationServiceProvider.overrideWithValue(
            TestNotificationService(),
          ),
        ],
        child: MaterialApp(
          initialRoute: '/drag_confirm',
          routes: AppRouter.routes,
        ),
      ),
    );

    // Verify the page title
    expect(find.text('Drag Confirm Button'), findsOneWidget);

    // Verify the DragConfirmButton is present
    expect(find.text('Slide to Confirm'), findsOneWidget);
  });

  testWidgets('DragConfirmButtonDemoPage allows dragging to confirm', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationServiceProvider.overrideWithValue(
            TestNotificationService(),
          ),
        ],
        child: MaterialApp(
          initialRoute: '/drag_confirm',
          routes: AppRouter.routes,
        ),
      ),
    );

    // 確保 widget 樹已經渲染完成
    await tester.pumpAndSettle();

    final dragButtons = find.byType(DragConfirmButton);
    expect(dragButtons, findsNWidgets(4));

    dragButtons.evaluate().forEach((element) {
      final dragButton = element.widget as DragConfirmButton;
      expect(dragButton.label, isNotEmpty);
    });

    final draggableAreas = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.key != null &&
          widget.key.toString().contains('drag_button_'),
    ).evaluate();

    for (final area in draggableAreas) {
      final container = area.widget as Container;
      await tester.drag(find.byWidget(container), const Offset(300.0, 0.0));

      await tester.pump(const Duration(seconds: 1)); // 等待動畫完成

      // 驗證是否觸發了 onConfirm 回調
      expect(
        find.text('Confirmed!'),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 2)); // 等待通知消失

      // 驗證通知已經消失
      expect(
        find.text('Confirmed!'),
        findsNothing,
      );
      break; // 只測試第一個拖動的按鈕
    }
  });
}
