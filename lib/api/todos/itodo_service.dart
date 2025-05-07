import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/api/http_client.dart';
import 'package:my_flutter_framework/api/paginated_response.dart';
import 'package:my_flutter_framework/api/todos/todo_service.dart';
import 'package:my_flutter_framework/mock/mock_todo_service.dart';

final todoServiceProvider = Provider<ITodoService>((ref) {
  // 判斷是否為測試環境
  final httpClient = ref.watch(httpClientProvider);
  if (kDebugMode) {
    return MockTodoService(httpClient);
  } else {
    return TodoService(httpClient);
  }
});

abstract class ITodoService {
  Future<PaginatedResponse<Map<String, dynamic>>> getTodos({int page = 1, int pageSize = 10});
  Future<void> addTodo(Map<String, dynamic> todo);
  Future<void> updateTodo(int id, Map<String, dynamic> updatedTodo);
  Future<void> deleteTodo(int id);
}