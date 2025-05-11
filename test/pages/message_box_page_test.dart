import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/api/notification/i_notification_service.dart';
import 'package:my_flutter_framework/pages/message/message_box_page.dart';
import 'package:my_flutter_framework/shared/utils/print_type.dart';

class TestNotificationService implements INotificationService {
  @override
  Stream<int> get notificationCountStream => Stream.value(0);

  @override
  void showNotification(String message) {
    // Mock implementation for testing
  }
}

void main() {
  group('MessageBoxPage Tests', () {
    testWidgets('should display all message box types', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationServiceProvider.overrideWithValue(
              TestNotificationService(),
            ),
          ],
          child: MaterialApp(home: MessageBoxPage())),
      );

      // Assert
      for (var type in PrintType.values) {
        expect(find.text(type.toString().split('.').last), findsOneWidget);
      }
    });

    testWidgets('should show message box when button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationServiceProvider.overrideWithValue(
              TestNotificationService(),
            ),
          ],
          child: MaterialApp(home: MessageBoxPage())),
      );
      // Act
      await tester.tap(find.text('Show').first);
      await tester.pump(Duration(seconds: 1)); // Simulate timer
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('This is a primary message box.'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should show tutorial steps when tutorial button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationServiceProvider.overrideWithValue(
              TestNotificationService(),
            ),
          ],
          child: MaterialApp(home: MessageBoxPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Act: 找到右上角教學按鈕 (通常是 IconButton 或 Tooltip 包含問號)
      final tutorialButton = find.byTooltip('教學');
      expect(tutorialButton, findsOneWidget, reason: '應該要有教學按鈕');
      await tester.tap(tutorialButton);
      await tester.pumpAndSettle();

      // Assert: 檢查第一個教學步驟標題與描述
      expect(find.text('訊息盒教學'), findsOneWidget);
      expect(find.textContaining('本頁展示各種訊息盒'), findsOneWidget);
    });
  });
}
