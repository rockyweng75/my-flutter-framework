import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/api/notification/i_notification_service.dart';
import 'package:my_flutter_framework/router/app_router.dart';

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
}
