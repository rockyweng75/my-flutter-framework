import 'dart:async';
import 'package:my_flutter_framework/api/http_client.dart';
import 'package:my_flutter_framework/api/todos/itodo_service.dart';
import 'package:my_flutter_framework/api/paginated_response.dart';

class MockTodoService implements ITodoService {
  final HttpClient _httpClient;

  MockTodoService(this._httpClient);

  final DateTime _today = DateTime.now();
  late final List<Map<String, dynamic>> _mockDatabase = [
    for (int i = 0; i < 10; i++)
      {
        'id': i + 1,
        'title': 'Mock Todo $i',
        'description': 'Description $i',
        'dueDate': _today.add(Duration(days: i ~/ 2)).toIso8601String().substring(0, 10),
        'priority': ['low', 'medium', 'high'][i % 3],
        'assignee': ((i % 3) + 1).toString(),
        'completed': i % 2 == 1,
      },
  ];

  @override
  Future<PaginatedResponse<Map<String, dynamic>>> getTodos({int page = 1, int pageSize = 10}) async {
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    if (startIndex >= _mockDatabase.length) {
      return PaginatedResponse(
        page: page,
        pageSize: pageSize,
        total: _mockDatabase.length,
        data: [],
      );
    }

    // 模擬網絡延遲
    await Future.delayed(const Duration(seconds: 1));

    final data = _mockDatabase.sublist(
      startIndex,
      endIndex > _mockDatabase.length ? _mockDatabase.length : endIndex,
    );
    return PaginatedResponse(
      page: page,
      pageSize: pageSize,
      total: _mockDatabase.length,
      data: data,
    );
  }

  @override
  Future<void> addTodo(Map<String, dynamic> todo) async {
    _mockDatabase.add(todo);
  }

  @override
  Future<void> updateTodo(int id, Map<String, dynamic> updatedTodo) async {
    final index = _mockDatabase.indexWhere((todo) => todo['id'] == id);
    if (index >= 0 && index < _mockDatabase.length) {
      _mockDatabase[index] = updatedTodo;
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    _mockDatabase.removeWhere((todo) => todo['id'] == id);
  }
}