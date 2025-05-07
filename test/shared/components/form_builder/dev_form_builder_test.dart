import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/shared/components/form_builder/dev_form_builder.dart';

void main() {
  group('DevFormBuilder', () {
    testWidgets('renders child widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DevFormBuilder(
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('shows form data dialog in testMode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DevFormBuilder(
              testMode: true,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: 'Test Value',
                    decoration: const InputDecoration(labelText: 'Test Field'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify the info button is present
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      // Tap the info button
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();

      // Verify the dialog is shown
      expect(find.text('Form Data'), findsOneWidget);
      expect(find.textContaining('Test Value'), findsOneWidget);

      // Close the dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Verify the dialog is dismissed
      expect(find.text('Form Data'), findsNothing);
    });

    testWidgets('does not show form data dialog when testMode is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DevFormBuilder(
              testMode: false,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: 'Test Value',
                    decoration: const InputDecoration(labelText: 'Test Field'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify the info button is not present
      expect(find.byIcon(Icons.info_outline), findsNothing);
    });

    testWidgets('handles FormBuilderDateTimePicker correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DevFormBuilder(
              testMode: true,
              child: Column(
                children: [
                  FormBuilderDateTimePicker(
                    name: 'dateTime',
                    initialValue: DateTime(2025, 5, 6),
                    decoration: const InputDecoration(labelText: 'Pick a Date'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify the info button is present
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      // Tap the info button
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();

      // Verify the dialog is shown
      expect(find.text('Form Data'), findsOneWidget);
      expect(find.textContaining('2025-05-06'), findsOneWidget);

      // Close the dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Verify the dialog is dismissed
      expect(find.text('Form Data'), findsNothing);
    });

    testWidgets('handles FormBuilderDateRangePicker correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DevFormBuilder(
              testMode: true,
              child: Column(
                children: [
                  FormBuilderDateRangePicker(
                    name: 'dateRange',
                    firstDate: DateTime(2025, 1, 1),
                    lastDate: DateTime(2025, 12, 31),
                    initialValue: DateTimeRange(
                      start: DateTime(2025, 5, 6),
                      end: DateTime(2025, 5, 13),
                    ),
                    decoration: const InputDecoration(labelText: 'Pick a Date Range'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify the info button is present
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      // Tap the info button
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();

      // Verify the dialog is shown
      expect(find.text('Form Data'), findsOneWidget);
      expect(find.textContaining('2025-05-06'), findsOneWidget);
      expect(find.textContaining('2025-05-13'), findsOneWidget);

      // Close the dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Verify the dialog is dismissed
      expect(find.text('Form Data'), findsNothing);
    });
  });
}