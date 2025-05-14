import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/shared/components/image_upload.dart';
import 'package:image_picker/image_picker.dart';

typedef OnImageSelected = void Function(XFile file);

void main() {
  testWidgets('ImageUpload 基本渲染', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImageUpload(),
        ),
      ),
    );
    expect(find.text('選擇圖片'), findsOneWidget);
    expect(find.byIcon(Icons.image), findsOneWidget);
  });

  testWidgets('ImageUpload 顯示自訂 label', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImageUpload(label: '上傳圖片'),
        ),
      ),
    );
    expect(find.text('上傳圖片'), findsOneWidget);
  });

  testWidgets('ImageUpload 點擊時可觸發 _showSourcePicker', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImageUpload(),
        ),
      ),
    );
    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();
    // 應該會出現底部選單
    expect(find.text('相機'), findsOneWidget);
    expect(find.text('硬碟/相簿'), findsOneWidget);
  });

  testWidgets('ImageUpload 選擇檔案後顯示檔名與刪除按鈕', (WidgetTester tester) async {
    final testKey = GlobalKey<State<ImageUpload>>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImageUpload(key: testKey),
        ),
      ),
    );
    final state = testKey.currentState as dynamic;
    state.setFileForTest('test_image.png', XFile('test_image.png'));
    await tester.pump();
    expect(find.textContaining('test_image'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('ImageUpload 點擊刪除按鈕會清空檔名', (WidgetTester tester) async {
    final testKey = GlobalKey<State<ImageUpload>>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImageUpload(key: testKey),
        ),
      ),
    );
    final state = testKey.currentState as dynamic;
    state.setFileForTest('test_image.png', XFile('test_image.png'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    // 驗證 UI 狀態，不直接驗證 private 欄位
    expect(find.text('選擇圖片'), findsOneWidget);
    expect(find.textContaining('test_image'), findsNothing);
  });

  testWidgets('ImageUpload debug 區塊顯示', (WidgetTester tester) async {
    final testKey = GlobalKey<State<ImageUpload>>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImageUpload(key: testKey, isDebug: true),
        ),
      ),
    );
    final state = testKey.currentState as dynamic;
    state.setFileForTest('debug_image.png', XFile('debug_image.png'));
    await tester.pump();
    expect(find.textContaining('[DEBUG]'), findsOneWidget);
    expect(find.textContaining('debug_image.png'), findsWidgets);
  });
}
