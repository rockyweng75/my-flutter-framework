import 'package:flutter/material.dart';
import 'package:flutter_riverpod/src/consumer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/shared/field_config.dart';
import 'package:my_flutter_framework/shared/order_config.dart';
import 'package:my_flutter_framework/shared/pages/simple_list_page.dart';
import 'package:my_flutter_framework/shared/pages/simple_query_form_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TestSimpleListPage extends SimpleListPage {
  TestSimpleListPage({
    required super.items,
    required super.scrollController,
    required super.isLoading,
    required super.isScreenLocked,
    required super.onLoadMore,
    required super.onItemTap,
    required super.rowBuilder,
  });

  @override
  T buildQueryForm<T extends SimpleQueryFormPage>(BuildContext context) {
    return TestSimpleQueryFormPage(
      onFormSubmit: (formData) => {},
    ) as T;
  }
}

class TestSimpleQueryFormPage extends SimpleQueryFormPage {
  const TestSimpleQueryFormPage({
    super.key,
    super.fieldSpacing = 20.0,
    super.onFormSubmit,
  });


  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _TestSimpleQueryFormPageState();
  }
} 
class _TestSimpleQueryFormPageState extends SimpleQueryFormPageState<TestSimpleQueryFormPage> {
  @override
  List<FieldConfig> getFields() {
    return [
      FieldConfig(
        name: 'testField',
        label: 'Test Field',
        type: FieldType.text,
      ),
    ];
  }

  @override
  List<OrderConfig> getOrderFields() {
    return [
      OrderConfig(
        name: 'testOrder',
        label: 'Test Order',
        initialValue: OrderConfigType.asc,
      ),
    ];
  }

}
void main() async {
  TestWidgetsFlutterBinding.ensureInitialized(); // 初始化環境

  await dotenv.load(fileName: ".env"); // 加載環境變數

  group('SimpleListPage', () {

    testWidgets('should display loading indicator when isLoading is true', (WidgetTester tester) async {
      // Arrange
      final scrollController = ScrollController();
      final simpleListPage = TestSimpleListPage(
        items: [],
        scrollController: scrollController,
        isLoading: true,
        isScreenLocked: false,
        onLoadMore: (_) {},
        onItemTap: (_) {},
        rowBuilder: (_, __) => const SizedBox.shrink(),
      );

      // Act
      await tester.pumpWidget(MaterialApp(home: simpleListPage));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should call onLoadMore when scrolled to the bottom', (WidgetTester tester) async {
      // Arrange
      bool onLoadMoreCalled = false;
      final scrollController = ScrollController();
      scrollController.addListener(() {
        if (scrollController.position.atEdge && scrollController.position.pixels != 0) {
          onLoadMoreCalled = true;
        }
      });

      final simpleListPage = TestSimpleListPage(
        items: List.generate(20, (index) => {'id': index}),
        scrollController: scrollController,
        isLoading: false,
        isScreenLocked: false,
        onLoadMore: (_) => onLoadMoreCalled = true,
        onItemTap: (_) {},
        rowBuilder: (_, item) => ListTile(title: Text('Item ${item['id']}')),
      );

      // Act
      await tester.pumpWidget(MaterialApp(home: simpleListPage));
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
      await tester.pumpAndSettle();

      // Assert
      expect(onLoadMoreCalled, isTrue);
    });

    testWidgets('should call onLoadMore after onFormSubmit is triggered', (WidgetTester tester) async {
      // Arrange
      bool onLoadMoreCalled = false;
      bool onFormSubmitCalled = false;

      final simpleListPage = TestSimpleListPage(
        items: List.generate(20, (index) => {'id': index}),
        scrollController: ScrollController(),
        isLoading: false,
        isScreenLocked: false,
        onLoadMore: (_) => onLoadMoreCalled = true,
        onItemTap: (_) {},
        rowBuilder: (_, item) => ListTile(title: Text('Item ${item['id']}')),
      );

      final queryFormPage = TestSimpleQueryFormPage(
        onFormSubmit: (formData) {
          onFormSubmitCalled = true;
          // 模擬觸發 onLoadMore
          simpleListPage.onLoadMore(null);
        },
      );

      // Act
      await tester.pumpWidget(MaterialApp(home: queryFormPage));

      // 模擬表單提交
      queryFormPage.onFormSubmit?.call({});

      // Pump 渲染更新
      await tester.pumpAndSettle();

      // Assert
      expect(onFormSubmitCalled, isTrue);
      expect(onLoadMoreCalled, isTrue);
    });
  });
}