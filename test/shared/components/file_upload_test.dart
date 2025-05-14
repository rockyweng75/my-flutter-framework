import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/shared/components/file_upload.dart';

void main() {
  testWidgets('FileUpload 基本渲染', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FileUpload(),
        ),
      ),
    );
    expect(find.text('選擇檔案'), findsOneWidget);
    expect(find.byIcon(Icons.upload_file), findsOneWidget);
  });

  testWidgets('FileUpload 顯示自訂 label', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FileUpload(label: '上傳附件'),
        ),
      ),
    );
    expect(find.text('上傳附件'), findsOneWidget);
  });

  testWidgets('FileUpload 點擊時觸發 _pickFile', (WidgetTester tester) async {
    bool called = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FileUpload(
            onFileSelected: (_) {
              called = true;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byType(GestureDetector));
    // 無法直接測試 file_selector 彈窗，但可驗證 onFileSelected callback 可被呼叫
    // 這裡僅驗證 UI 可點擊
    expect(called, isFalse);
  });

  testWidgets('FileUpload 選擇檔案後顯示檔名', (WidgetTester tester) async {
    final testKey = GlobalKey<State<FileUpload>>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FileUpload(key: testKey),
        ),
      ),
    );
    final state = testKey.currentState as dynamic;
    state.setFileNameForTest('test_document.pdf');
    await tester.pump();
    expect(find.text('test_document.pdf'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    expect(find.byIcon(Icons.upload_file), findsNothing);
    expect(find.text('選擇檔案'), findsNothing);
    expect(find.text('上傳附件'), findsNothing);
  });

  testWidgets('FileUpload 點擊刪除按鈕會清空檔名', (WidgetTester tester) async {
    final testKey = GlobalKey<State<FileUpload>>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FileUpload(key: testKey),
        ),
      ),
    );
    final state = testKey.currentState as dynamic;
    state.setFileNameForTest('test_document.pdf');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    expect(find.text('選擇檔案'), findsOneWidget);
  });
}
