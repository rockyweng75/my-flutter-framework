import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/pages/message/message_box_page.dart';
import 'package:my_flutter_framework/shared/utils/print_type.dart';

void main() {
  group('MessageBoxPage Tests', () {
    testWidgets('should display all message box types', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: MessageBoxPage(),
        ),
      );

      // Assert
      for (var type in PrintType.values) {
        expect(find.text(type.toString().split('.').last), findsOneWidget);
      }
    });

    testWidgets('should show message box when button is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: MessageBoxPage(),
        ),
      );

      // Act
      await tester.tap(find.text('Show').first);
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