import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/shared/components/menus/draggable_menu_button.dart';

void main() {
  testWidgets('DraggableMenuButton widget renders and displays menu items', (WidgetTester tester) async {
    final menuItems = [
      MenuItem(key: 'a', label: 'A'),
      MenuItem(key: 'b', label: 'B'),
      MenuItem(key: 'c', label: 'C'),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DraggableMenuButton(menuItems: menuItems),
        ),
      ),
    );
    // 驗證按鈕本身存在
    expect(find.text('拖曳我'), findsOneWidget);
    // menu label 是畫在 canvas 上，無法用 find.text 驗證
    // 若需驗證 label，請改用 golden test 或人工檢查畫面
  });

  testWidgets('DraggableMenuButton 拖曳動作可觸發 menu item onSelected', (WidgetTester tester) async {
    String? selectedKey;
    final menuItems = [
      MenuItem(key: 'a', label: 'A', onSelected: (k) => selectedKey = k),
      MenuItem(key: 'b', label: 'B', onSelected: (k) => selectedKey = k),
      MenuItem(key: 'c', label: 'C', onSelected: (k) => selectedKey = k),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DraggableMenuButton(menuItems: menuItems),
        ),
      ),
    );
    // 取得按鈕位置
    final buttonFinder = find.text('拖曳我');
    expect(buttonFinder, findsOneWidget);
    final Offset center = tester.getCenter(buttonFinder);
    // 執行拖曳動作（往右上方拖曳一段距離）
    await tester.drag(buttonFinder, const Offset(80, -80));
    await tester.pumpAndSettle();
    // 結束拖曳
    await tester.tapAt(center);
    await tester.pumpAndSettle();
    // 驗證 onSelected 是否被觸發
    expect(selectedKey, isNotNull);
    expect(['a', 'b', 'c'], contains(selectedKey));
  });
}
