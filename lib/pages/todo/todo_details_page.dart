import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:my_flutter_framework/api/assignee/iassignee_service.dart';
import 'package:my_flutter_framework/api/todos/itodo_service.dart';
import 'package:my_flutter_framework/models/assignee.dart';
import 'package:my_flutter_framework/shared/field_config.dart';
import 'package:my_flutter_framework/shared/pages/simple_form_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class TodoDetailsPage extends SimpleFormPage {
  final Map<String, dynamic> todo;

  TodoDetailsPage({
    required this.todo,
    super.viewMode = ViewMode.view,
    super.key,
  }) : super(title: 'Todo Details');

  @override
  ConsumerState<SimpleFormPage> createState() => _TodoDetailsPageState();
}

class _TodoDetailsPageState extends SimpleFormPageState<TodoDetailsPage> {
  late final IAssigneeService _assigneeService;
  late final ITodoService _todoService;

  @override
  void initState() {
    super.initState();
    _assigneeService = ref.read(assigneeServiceProvider);
    _todoService = ref.read(todoServiceProvider);
  }

  @override
  String getPageTitle() => 'Todo Details';

  Future<List<Assignee>> _fetchAssignees({
    String? keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _assigneeService.getAssignees(
      keyword: keyword,
      page: page,
      pageSize: pageSize,
    );
    return response.data;
  }

  @override
  List<FieldConfig> getFields() {
    return [
      FieldConfig(
        name: 'title',
        label: 'Title',
        value: widget.todo['title'],
        validator: FormBuilderValidators.required(),
        enabled: !isViewMode,
      ),
      FieldConfig(
        name: 'description',
        label: 'Description',
        value: widget.todo['description'],
        enabled: !isViewMode,
      ),
      FieldConfig(
        name: 'dueDate',
        label: 'Due Date',
        value: widget.todo['dueDate'],
        type: FieldType.datePicker,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
        enabled: !isViewMode,
      ),
      FieldConfig(
        name: 'priority',
        label: 'Priority',
        value: widget.todo['priority'],
        type: FieldType.dropdown,
        optionsProvider: (keyword, page, perPage) async {
          return {'low': 'Low', 'medium': 'Medium', 'high': 'High'};
        },
        validator: FormBuilderValidators.required(),
        enabled: !isViewMode,
      ),
      FieldConfig(
        name: 'assignee',
        label: 'Assignee',
        value: widget.todo['assignee'],
        type: FieldType.searchableDropdown,
        optionsProvider: (keyword, page, perPage) async {
          final resolvedPage = page ?? 1; // 預設值為 1
          final resolvedPerPage = perPage ?? 20; // 預設值為 20
          final assignees = await _fetchAssignees(
            keyword: keyword,
            page: resolvedPage,
            pageSize: resolvedPerPage,
          );
          return Map.fromEntries(
            assignees.map(
              (assignee) => MapEntry(assignee.id.toString(), assignee.name),
            ),
          );
        },
        validator: FormBuilderValidators.required(),
        enabled: !isViewMode,
      ),
      FieldConfig(
        name: 'image',
        label: '圖片',
        type: FieldType.imageUpload,
        validator: (value) {
          if (value == null || value.isEmpty) return '請選擇圖片';
          final file = File(value);
          if (!file.existsSync()) return '圖片不存在';
          final size = file.lengthSync();
          if (size > 5 * 1024 * 1024) return '圖片需小於 5MB';
          return null;
        },
        enabled: !isViewMode,
      ),

      FieldConfig(
        name: 'file',
        label: '檔案',
        type: FieldType.fileUpload,
        validator: (value) {
          if (value == null || value.isEmpty) return '請選擇檔案';
          final file = File(value);
          if (!file.existsSync()) return '檔案不存在';
          final size = file.lengthSync();
          if (size > 5 * 1024 * 1024) return '檔案需小於 5MB';
          return null;
        },
        enabled: !isViewMode,
      ),
    ];
  }

  @override
  Future<void> onSave(Map<String, dynamic> formData) async {
    if (isViewMode) return;

    if (isEditMode) {
      // 編輯模式下，更新 Todo
      final updatedTodo = {...widget.todo, ...formData};
      await _todoService.updateTodo(widget.todo['id'], updatedTodo);
      Navigator.pop(context, updatedTodo);
    } else if (isCreateMode) {
      // 創建模式下，創建新的 Todo
      final newTodo = {...formData};
      await _todoService.addTodo(newTodo);
      Navigator.pop(context, newTodo);
    }
  }

  @override
  Future<void> onDelete(Map<String, dynamic> formData) async {
    if (isViewMode) return;

    // 刪除 Todo
    await _todoService.deleteTodo(widget.todo['id']);
    Navigator.pop(context, null);
  }
}
