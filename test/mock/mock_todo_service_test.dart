import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/api/http_client.dart';
import 'package:my_flutter_framework/api/todos/itodo_service.dart';
import 'package:my_flutter_framework/mock/mock_todo_service.dart';

void main() {
  group('MockTodoService Tests', () {
    late ITodoService todoService;
    late HttpClient httpClient;

    setUp(() {
      httpClient = HttpClient('https://example.com');
      todoService = MockTodoService(httpClient);
    });

    test('should fetch paginated todos', () async {
      final response = await todoService.getTodos(page: 1, pageSize: 2);
      expect(response.page, 1);
      expect(response.pageSize, 2);
      expect(response.data, isA<List<Map<String, dynamic>>>());
    });

    test('should add a new todo', () async {
      final newTodo = {'id': 11, 'title': 'New Todo', 'completed': false};
      todoService.addTodo(newTodo);

      // Assuming the service has a way to fetch all todos to verify
      final response = await todoService.getTodos(page: 1, pageSize: 20);
      expect(response.data.any((todo) => todo['title'] == 'New Todo'), isTrue);
    });

    test('should update an existing todo', () async {
      final updatedTodo = {'id': 1, 'title': 'Updated Todo', 'completed': true};
      todoService.updateTodo(1, updatedTodo);

      // Assuming the service has a way to fetch all todos to verify
      final response = await todoService.getTodos(page: 1, pageSize: 20);
      expect(response.data.any((todo) => todo['title'] == 'Updated Todo'), isTrue);
    });

    test('should delete a todo', () async {
      todoService.deleteTodo(1);

      // Assuming the service has a way to fetch all todos to verify
      final response = await todoService.getTodos(page: 1, pageSize: 20);
      expect(response.data.any((todo) => todo['id'] == 1), isFalse);
    });
  });
}