import 'dart:async';
import 'package:my_flutter_framework/api/http_client.dart';
import 'package:my_flutter_framework/api/todos/itodo_service.dart';
import 'package:my_flutter_framework/api/paginated_response.dart';

class MockTodoService implements ITodoService {
  final HttpClient _httpClient;

  MockTodoService(this._httpClient);

  final List<Map<String, dynamic>> _mockDatabase = [
    {'id': 1, 'title': 'Mock Todo 1', 'description': 'Description 1', 'dueDate': '2025-05-01', 'priority': 'low', 'assignee': '1', 'completed': false},
    {'id': 2, 'title': 'Mock Todo 2', 'description': 'Description 2', 'dueDate': '2025-05-02', 'priority': 'medium', 'assignee': '2', 'completed': true},
    {'id': 3, 'title': 'Mock Todo 3', 'description': 'Description 3', 'dueDate': '2025-05-03', 'priority': 'high', 'assignee': '3', 'completed': false},
    {'id': 4, 'title': 'Mock Todo 4', 'description': 'Description 4', 'dueDate': '2025-05-04', 'priority': 'low', 'assignee': '1', 'completed': true},
    {'id': 5, 'title': 'Mock Todo 5', 'description': 'Description 5', 'dueDate': '2025-05-05', 'priority': 'medium', 'assignee': '2', 'completed': false},
    {'id': 6, 'title': 'Mock Todo 6', 'description': 'Description 6', 'dueDate': '2025-05-06', 'priority': 'high', 'assignee': '3', 'completed': true},
    {'id': 7, 'title': 'Mock Todo 7', 'description': 'Description 7', 'dueDate': '2025-05-07', 'priority': 'low', 'assignee': '1', 'completed': false},
    {'id': 8, 'title': 'Mock Todo 8', 'description': 'Description 8', 'dueDate': '2025-05-08', 'priority': 'medium', 'assignee': '2', 'completed': true},
    {'id': 9, 'title': 'Mock Todo 9', 'description': 'Description 9', 'dueDate': '2025-05-09', 'priority': 'high', 'assignee': '3', 'completed': false},
    {'id': 10, 'title': 'Mock Todo 10', 'description': 'Description 10', 'dueDate': '2025-05-10', 'priority': 'low', 'assignee': '1', 'completed': true},
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