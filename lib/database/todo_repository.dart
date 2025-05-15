import 'package:my_flutter_framework/database/hive_repository.dart';
import 'package:my_flutter_framework/models/todo.dart';

class TodoRepository {
  static const String _boxName = 'todoBox';
  static const String _idKey = '_maxId';

  /// 新增或更新 Todo
  static Future<void> upsertTodo(Todo todo) async {
    await HiveRepository.openBox(_boxName);
    await HiveRepository.putModel(
      _boxName,
      todo.id.toString(),
      () => todo.toJson(),
    );
  }

  /// 刪除 Todo
  static Future<void> deleteTodo(int id) async {
    await HiveRepository.openBox(_boxName);
    await HiveRepository.delete(_boxName, id.toString());
  }

  /// 取得所有 Todo，支援分頁、排序與多條件查詢
  static Future<List<Todo>> getAllTodos({
    int? page,
    int? pageSize,
    int Function(Todo a, Todo b)? sort,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? status,
    String? keyword,
  }) async {
    await HiveRepository.openBox(_boxName);
    final box = HiveRepository.getBox(_boxName);
    List<Todo> todos = box.values
        .whereType<Map>()
        .map((e) => Todo.fromJson(Map<String, dynamic>.from(e)))
        .where((todo) {
          final matchStart = startDate == null || !todo.endTime.isBefore(startDate);
          final matchEnd = endDate == null || !todo.startTime.isAfter(endDate);
          final matchLocation = location == null || (todo.location?.contains(location) ?? false);
          final matchStatus = status == null || todo.status == status;
          final matchKeyword = keyword == null ||
            todo.title.contains(keyword) ||
            (todo.content?.contains(keyword) ?? false) ||
            (todo.location?.contains(keyword) ?? false);
          return matchStart && matchEnd && matchLocation && matchStatus && matchKeyword;
        })
        .toList();
    if (sort != null) {
      todos.sort(sort);
    }
    if (page != null && pageSize != null) {
      final start = (page - 1) * pageSize;
      final end = start + pageSize;
      if (start < todos.length) {
        todos = todos.sublist(start, end > todos.length ? todos.length : end);
      } else {
        todos = [];
      }
    }
    return todos;
  }

  /// 取得單一 Todo
  static Future<Todo?> getTodo(int id) async {
    await HiveRepository.openBox(_boxName);
    return HiveRepository.getAsModel<Todo>(
      _boxName,
      id.toString(),
      fromMap: (data) => Todo.fromJson(data),
    );
  }

  /// 新增 Todo（自動產生 id，並將最新 id 存在 _idKey）
  static Future<Todo> addTodo(Todo todo) async {
    await HiveRepository.openBox(_boxName);
    final box = HiveRepository.getBox(_boxName);
    // 從 box 取得目前最大 id
    int maxId = box.get(_idKey, defaultValue: 0) as int? ?? 0;
    final newId = maxId + 1;
    final newTodo = Todo(
      id: newId,
      title: todo.title,
      startTime: todo.startTime,
      endTime: todo.endTime,
      status: todo.status,
      content: todo.content,
      location: todo.location,
      attachments: todo.attachments,
      assignee: todo.assignee,
    );
    await HiveRepository.putModel(
      _boxName,
      newId.toString(),
      () => newTodo.toJson(),
    );
    // 更新 id 記錄
    await box.put(_idKey, newId);
    return newTodo;
  }
}
