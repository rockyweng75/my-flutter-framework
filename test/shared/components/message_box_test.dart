import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/shared/components/message_box.dart';
import 'package:my_flutter_framework/shared/utils/print_type.dart';

void main() {
  group('MessageBox Widget Tests', () {
    testWidgets('displays title and message correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MessageBox(
            title: 'Test Title',
            message: 'Test Message',
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Message'), findsOneWidget);
    });

    testWidgets('displays correct icon for MessageBoxType', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MessageBox(
            title: 'Info',
            message: 'This is an info message.',
            type: PrintType.info,
          ),
        ),
      );

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('calls onConfirm when Confirm button is pressed', (WidgetTester tester) async {
      bool confirmCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MessageBox(
            title: 'Confirm Test',
            message: 'Press confirm to test.',
            onConfirm: () {
              confirmCalled = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(confirmCalled, isTrue);
    });

    testWidgets('calls onCancel when Cancel button is pressed', (WidgetTester tester) async {
      bool cancelCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MessageBox(
            title: 'Cancel Test',
            message: 'Press cancel to test.',
            onCancel: () {
              cancelCalled = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(cancelCalled, isTrue);
    });

    testWidgets('does not call onConfirm when Confirm button is not pressed', (WidgetTester tester) async {
      bool confirmCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MessageBox(
            title: 'Confirm Test',
            message: 'Do not press confirm.',
            onConfirm: () {
              confirmCalled = true;
            },
          ),
        ),
      );

      // Do not tap the Confirm button
      await tester.pumpAndSettle();

      expect(confirmCalled, isFalse);
    });

    testWidgets('does not call onCancel when Cancel button is not pressed', (WidgetTester tester) async {
      bool cancelCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MessageBox(
            title: 'Cancel Test',
            message: 'Do not press cancel.',
            onCancel: () {
              cancelCalled = true;
            },
          ),
        ),
      );

      // Do not tap the Cancel button
      await tester.pumpAndSettle();

      expect(cancelCalled, isFalse);
    });

    testWidgets('displays long title and message correctly', (WidgetTester tester) async {
      final longTitle = 'This is a very long title that should wrap or truncate properly in the MessageBox widget. It is intentionally made long to test the behavior of the widget when handling large amounts of text.';
      final longMessage = 'This is a very long message that should also wrap or truncate properly in the MessageBox widget. The message is intentionally verbose and contains multiple sentences to simulate a real-world scenario where a lot of information needs to be displayed to the user. This test ensures that the widget can handle such cases gracefully without breaking the layout or causing unexpected behavior.';

      await tester.pumpWidget(
        MaterialApp(
          home: MessageBox(
            title: longTitle,
            message: longMessage,
          ),
        ),
      );

      expect(find.textContaining('This is a very long title'), findsOneWidget);
      expect(find.textContaining('This is a very long message'), findsOneWidget);
    });
  });
}