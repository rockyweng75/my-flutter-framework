import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/api/notification/i_notification_service.dart';
import 'package:my_flutter_framework/api/notification/notification_service.dart';
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
  });
}
