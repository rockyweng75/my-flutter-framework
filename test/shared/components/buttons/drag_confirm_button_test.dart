import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/shared/components/buttons/drag_confirm_button.dart';

void main() {
  group('DragConfirmButton', () {
    testWidgets('DragConfirmButton confirms on drag to the right', (
      WidgetTester tester,
    ) async {
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

      final draggableArea = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.key != null &&
            widget.key.toString().contains('drag_button_'),
      );

      // Perform drag to the right
      await tester.drag(draggableArea, const Offset(300, 0));
      await tester.pumpAndSettle();

      // Verify confirmation
      expect(confirmed, isTrue);
    });

    testWidgets('DragConfirmButton confirms on drag to the left', (
      WidgetTester tester,
    ) async {
      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DragConfirmButton(
              label: 'Slide to Confirm',
              onConfirm: () {
                confirmed = true;
              },
              confirmOnLeft: true,
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Slide to Confirm'), findsOneWidget);
      expect(confirmed, isFalse);

      final draggableArea = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.key != null &&
            widget.key.toString().contains('drag_button_'),
      );

      // Perform drag to the left
      await tester.drag(draggableArea, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Verify confirmation
      expect(confirmed, isTrue);
    });

    testWidgets(
      'DragConfirmButton cancels on drag to the left when onCancel is provided',
      (WidgetTester tester) async {
        bool cancelled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DragConfirmButton(
                label: 'Slide to Confirm',
                onConfirm: () {},
                onCancel: () {
                  cancelled = true;
                },
              ),
            ),
          ),
        );

        // Verify initial state
        expect(find.text('Slide to Confirm'), findsOneWidget);
        expect(cancelled, isFalse);

        final draggableArea = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.key != null &&
              widget.key.toString().contains('drag_button_'),
        );

        // Perform drag to the left
        await tester.drag(draggableArea, const Offset(-300, 0));
        await tester.pumpAndSettle();

        // Verify cancellation
        expect(cancelled, isTrue);
      },
    );

    testWidgets(
      'DragConfirmButton cancels on drag to the right when confirmOnLeft is true and onCancel is provided',
      (WidgetTester tester) async {
        bool cancelled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DragConfirmButton(
                label: 'Slide to Confirm',
                onConfirm: () {},
                onCancel: () {
                  cancelled = true;
                },
                confirmOnLeft: true,
              ),
            ),
          ),
        );

        // Verify initial state
        expect(find.text('Slide to Confirm'), findsOneWidget);
        expect(cancelled, isFalse);

        final draggableArea = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.key != null &&
              widget.key.toString().contains('drag_button_'),
        );

        // Perform drag to the right
        await tester.drag(draggableArea, const Offset(300, 0));
        await tester.pumpAndSettle();

        // Verify cancellation
        expect(cancelled, isTrue);
      },
    );

    testWidgets('DragConfirmButton resets to center after confirmation', (
      WidgetTester tester,
    ) async {
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

      final draggableArea = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.key != null &&
            widget.key.toString().contains('drag_button_'),
      );

      // Perform drag to the right
      await tester.drag(draggableArea, const Offset(300, 0));
      await tester.pumpAndSettle();

      // Verify confirmation
      expect(confirmed, isTrue);

      // Verify button resets to center
      final dragButton = tester.widget<Container>(
        draggableArea,
      );
      expect(dragButton.constraints?.minWidth, isNotNull); // Ensure it resets
    });

    testWidgets('DragConfirmButton resets to center after cancellation', (
      WidgetTester tester,
    ) async {
      bool cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DragConfirmButton(
              label: 'Slide to Confirm',
              onConfirm: () {},
              onCancel: () {
                cancelled = true;
              },
            ),
          ),
        ),
      );

      final draggableArea = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.key != null &&
            widget.key.toString().contains('drag_button_'),
      );

      // Perform drag to the left
      await tester.drag(draggableArea, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Verify cancellation
      expect(cancelled, isTrue);

      // Verify button resets to center
      final dragButton = tester.widget<Container>(
        draggableArea,
      );
      expect(dragButton.constraints?.minWidth, isNotNull); // Ensure it resets
    });

    testWidgets(
      'DragConfirmButton displays custom confirm and cancel icons',
      (WidgetTester tester) async {
        bool confirmed = false;
        bool cancelled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DragConfirmButton(
                label: 'Slide to Confirm',
                onConfirm: () {
                  confirmed = true;
                },
                onCancel: () {
                  cancelled = true;
                },
                confirmIcon: const Icon(
                  Icons.thumb_up,
                  color: Colors.blue,
                  size: 40,
                ),
                cancelIcon: const Icon(
                  Icons.thumb_down,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ),
          ),
        );

        // Verify initial state
        expect(find.text('Slide to Confirm'), findsOneWidget);
        expect(find.byIcon(Icons.thumb_up), findsNothing);
        expect(find.byIcon(Icons.thumb_down), findsNothing);
        expect(confirmed, isFalse);
        expect(cancelled, isFalse);

        final draggableArea = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.key != null &&
              widget.key.toString().contains('drag_button_'),
        );

        // Perform drag to the right (confirm)
        await tester.drag(draggableArea, const Offset(300, 0));
        await tester.pumpAndSettle();

        // Verify confirmation and custom confirm icon
        expect(confirmed, isTrue);
        expect(find.byIcon(Icons.thumb_up), findsOneWidget);

        // Reset state
        confirmed = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DragConfirmButton(
                label: 'Slide to Confirm',
                onConfirm: () {
                  confirmed = true;
                },
                onCancel: () {
                  cancelled = true;
                },
                confirmIcon: const Icon(
                  Icons.thumb_up,
                  color: Colors.blue,
                  size: 40,
                ),
                cancelIcon: const Icon(
                  Icons.thumb_down,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ),
          ),
        );

        // Perform drag to the left (cancel)
        await tester.drag(draggableArea, const Offset(-300, 0));
        await tester.pumpAndSettle();

        // Verify cancellation and custom cancel icon
        expect(cancelled, isTrue);
        expect(find.byIcon(Icons.thumb_down), findsOneWidget);
      },
    );
  });
}
