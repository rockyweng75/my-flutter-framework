import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:my_flutter_framework/adapters/fileSystem/web_file_system_adapter_stub.dart';
import 'package:my_flutter_framework/api/assignee/iassignee_service.dart';
import 'package:my_flutter_framework/models/assignee.dart';
import 'package:my_flutter_framework/shared/field_config.dart';
import 'package:my_flutter_framework/shared/pages/simple_form_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/database/todo_repository.dart';
import 'package:my_flutter_framework/models/todo.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:my_flutter_framework/adapters/fileSystem/file_system_adapter.dart';

class TodoDetailsPage extends SimpleFormPage {
  final Map<String, dynamic> todo;

  const TodoDetailsPage({
    required this.todo,
    super.viewMode = ViewMode.view,
    super.key,
    super.id,
  }) : super(title: 'Todo Details');

  @override
  ConsumerState<SimpleFormPage> createState() => _TodoDetailsPageState();
}

class _TodoDetailsPageState extends SimpleFormPageState<TodoDetailsPage> {
  late final IAssigneeService _assigneeService;
  late final FileSystemAdapter _fileSystemAdapter;

  @override
  void initState() {
    super.initState();
    _assigneeService = ref.read(assigneeServiceProvider);
    _fileSystemAdapter = ref.read(fileSystemAdapterProvider);
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
        required: true,
      ),
      FieldConfig(
        name: 'content',
        label: 'Content',
        value: widget.todo['content'],
        enabled: !isViewMode,
        config: {'maxLines': 5, 'minLines': 3},
        required: true,
      ),
      FieldConfig(
        name: 'startTime',
        label: 'Start Time',
        value: widget.todo['startTime'],
        type: FieldType.datePicker,
        validator: FormBuilderValidators.required(),
        enabled: !isViewMode,
        required: true,
      ),
      FieldConfig(
        name: 'endTime',
        label: 'End Time',
        value: widget.todo['endTime'],
        type: FieldType.datePicker,
        validator: FormBuilderValidators.required(),
        enabled: !isViewMode,
        required: true,
      ),
      FieldConfig(
        name: 'status',
        label: 'Status',
        value: widget.todo['status'],
        type: FieldType.dropdown,
        optionsProvider: (keyword, page, perPage) async {
          return {'open': 'Open', 'done': 'Done', 'pending': 'Pending'};
        },
        validator: FormBuilderValidators.required(),
        enabled: !isViewMode,
      ),
      FieldConfig(
        name: 'location',
        label: 'Location',
        value: widget.todo['location'],
        enabled: !isViewMode,
      ),
      FieldConfig(
        name: 'attachments',
        label: 'Attachments',
        value: widget.todo['attachments'] is List && (widget.todo['attachments'] as List).isNotEmpty
            ? (widget.todo['attachments'] as List).first
            : widget.todo['attachments'],
        type: FieldType.fileUpload,
        enabled: !isViewMode,
      ),
      FieldConfig(
        name: 'assignee',
        label: 'Assignee',
        value: widget.todo['assignee'],
        type: FieldType.searchableDropdown,
        optionsProvider: (keyword, page, perPage) async {
          final resolvedPage = page ?? 1;
          final resolvedPerPage = perPage ?? 20;
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
        enabled: !isViewMode, // 保證為 bool
      ),
    ];
  }

  @override
  Future<void> onSave(dynamic id, Map<String, dynamic> formData) async {
    if (isViewMode) return;
    Map<String, dynamic> safeFormData = Map.from(formData);
    for (var key in ['startTime', 'endTime']) {
      if (safeFormData[key] is DateTime) {
        safeFormData[key] = (safeFormData[key] as DateTime).toIso8601String();
      }
    }
    // 將 attachments 轉換為 List<String>，確保每個元素都是 String
    if (safeFormData['attachments'] is String) {
      safeFormData['attachments'] = [safeFormData['attachments']];
    }

    // attachments 處理
    if (safeFormData['attachments'] != null &&
        safeFormData['attachments'] is List) {
      List attachments = safeFormData['attachments'];
      List<String> localPaths = [];
      for (var file in attachments) {
        if (file is String && file.startsWith('/')) {
          // 已是本地路徑
          localPaths.add(file);
        } else if (file is XFile) {
          // XFile 轉 local file
          final bytes = await file.readAsBytes();
          final savedPath = await _fileSystemAdapter.saveFile(file.name, bytes);
          localPaths.add(savedPath);
        } else if (file is File) {
          // File 轉 local file（複製一份到 app local）
          final bytes = await file.readAsBytes();
          final fileName = file.uri.pathSegments.last;
          final savedPath = await _fileSystemAdapter.saveFile(fileName, bytes);
          localPaths.add(savedPath);
        } else if (file is String && file.startsWith('blob:')) {
          final savedPath = await _fileSystemAdapter.saveFile(file, Uint8List(0));
          localPaths.add(savedPath);
        }
      }
      // 保證 attachments 為 List<String>，且每個元素都是 String
      safeFormData['attachments'] = List<String>.from(localPaths);
    }

    if (isEditMode) {
      final updatedTodo = Todo.fromJson({
        'id': id,
        ...widget.todo,
        ...safeFormData,
      });
      await TodoRepository.upsertTodo(updatedTodo);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('儲存成功')));
        // 確保回傳 Map<String, dynamic> 結構
        Navigator.pop(context, updatedTodo.toJson());
      }
    } else if (isCreateMode) {
      final newTodo = Todo.fromJson({'id': id, ...safeFormData});
      final created = await TodoRepository.addTodo(newTodo);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('新增成功')));
        // 確保回傳 Map<String, dynamic> 結構
        Navigator.pop(context, created.toJson());
      }
    }
  }

  @override
  Future<void> onDelete(dynamic id, Map<String, dynamic> formData) async {
    if (isViewMode) return;
    await TodoRepository.deleteTodo(widget.todo['id']);
    Navigator.pop(context, null);
  }
}
