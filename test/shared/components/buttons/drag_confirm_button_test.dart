import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/shared/components/buttons/drag_confirm_button.dart';

void main() {
  testWidgets('DragConfirmButton confirms on drag to the right', (WidgetTester tester) async {
    bool confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DragConfirmButton(
            label: 'Slide to Confirm',
            onConfirm: () {
              confirmed = true;
            },
          ),
        ),
      ),
    );

    // Verify initial state
    expect(find.text('Slide to Confirm'), findsOneWidget);
    expect(confirmed, isFalse);

    // Perform drag to the right
    await tester.drag(find.byType(DragConfirmButton), const Offset(300, 0));
    await tester.pumpAndSettle();

    // Verify confirmation
    expect(confirmed, isTrue);
  });

  testWidgets('DragConfirmButton confirms on drag to the left', (WidgetTester tester) async {
    bool confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DragConfirmButton(
            label: 'Slide to Confirm',
            onConfirm: () {
              confirmed = true;
            },
          ),
        ),
      ),
    );

    // Verify initial state
    expect(find.text('Slide to Confirm'), findsOneWidget);
    expect(confirmed, isFalse);

    // Perform drag to the left
    await tester.drag(find.byType(DragConfirmButton), const Offset(-300, 0));
    await tester.pumpAndSettle();

    // Verify confirmation
    expect(confirmed, isTrue);
  });
}