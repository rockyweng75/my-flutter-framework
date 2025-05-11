import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_button.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_step.dart';
import 'package:my_flutter_framework/shared/components/tutorial/gesture_type.dart';

void main() {
  testWidgets('TutorialButton 顯示與互動測試', (WidgetTester tester) async {
    final steps = [
      TutorialStep(title: 'Step 1', description: '說明1'),
      TutorialStep(
        title: 'Step 2',
        description: '說明2',
        gestureType: GestureType.swipeLeft,
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TutorialButton(steps: steps))),
    );

    // 應該有 IconButton
    expect(find.byType(IconButton), findsOneWidget);

    // 點擊 IconButton 彈出教學 Dialog
    await tester.tap(find.byType(IconButton));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Step 1'), findsOneWidget);
    expect(find.text('說明1'), findsOneWidget);

    // 點擊下一步
    await tester.tap(find.widgetWithText(ElevatedButton, '下一步'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Step 2'), findsOneWidget);
    expect(find.text('說明2'), findsOneWidget);

    // 點擊完成
    await tester.tap(find.widgetWithText(ElevatedButton, '完成'));
    await tester.pump(); // 先 pump 一次
    await tester.pump(const Duration(milliseconds: 300)); // 再多等一點
    expect(find.byType(Dialog), findsNothing);
  });
}
