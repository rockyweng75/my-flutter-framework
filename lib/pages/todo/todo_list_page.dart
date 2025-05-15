import 'package:flutter/material.dart';
import 'package:my_flutter_framework/pages/todo/todo_query_form_page.dart';
import 'package:my_flutter_framework/shared/pages/simple_list_page.dart';
import 'package:my_flutter_framework/shared/pages/simple_query_form_page.dart';
class TodoListPage extends SimpleListPage {
  TodoListPage({
    super.key,
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
    return TodoQueryFormPage(
      fieldSpacing: 20.0,
      onFormSubmit: (formData) {
        onLoadMore(formData);
        return formData;
      },
    ) as T;
  }
}
