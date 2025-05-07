import 'package:my_flutter_framework/api/http_client.dart';
import 'package:my_flutter_framework/api/todos/itodo_service.dart';
import 'package:my_flutter_framework/api/paginated_response.dart';

class TodoService implements ITodoService {
  final HttpClient _httpClient;

  TodoService(this._httpClient);

  @override
  Future<PaginatedResponse<Map<String, dynamic>>> getTodos({int page = 1, int pageSize = 10}) async {
    final response = await _httpClient.get<List<Map<String, dynamic>>>(
      '/todos?page=$page&pageSize=$pageSize',
      fromJson: (json) => List<Map<String, dynamic>>.from(json),
    );
    return PaginatedResponse(
      page: page,
      pageSize: pageSize,
      total: response.length,
      data: response,
    );
  }

  @override
  Future<void> addTodo(Map<String, dynamic> todo) async {
    await _httpClient.post('/todos', body: todo);
  }

  @override
  Future<void> updateTodo(int id, Map<String, dynamic> updatedTodo) async {
    await _httpClient.put('/todos/$id', body: updatedTodo);
  }

  @override
  Future<void> deleteTodo(int id) async {
    await _httpClient.delete('/todos/$id');
  }
}