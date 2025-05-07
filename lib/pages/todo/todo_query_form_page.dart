import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/shared/field_config.dart';
import 'package:my_flutter_framework/shared/order_config.dart';
import 'package:my_flutter_framework/shared/pages/simple_query_form_page.dart';

class TodoQueryFormPage extends SimpleQueryFormPage {
  const TodoQueryFormPage({super.key, super.fieldSpacing = 20.0, super.onFormSubmit});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _TodoQueryFormPageState();
  }

}

class _TodoQueryFormPageState extends SimpleQueryFormPageState<TodoQueryFormPage> {
  @override
  List<FieldConfig> getFields() {
    return [
      FieldConfig(
        name: 'title',
        label: '標題',
        type: FieldType.text,
      ),
      FieldConfig(
        name: 'status',
        label: '狀態',
        type: FieldType.dropdown,
        optionsProvider: (keyword, page, perPage) async {
          return {
            '1': '待辦',
            '2': '完成',
            '3': '取消',
          };
        },
      ),
    ];
  }

  @override
  List<OrderConfig> getOrderFields() {
    return [
      OrderConfig(
        name: 'id',
        label: '建立時間',
        initialValue: OrderConfigType.desc,
      ),
    ];
  }
}