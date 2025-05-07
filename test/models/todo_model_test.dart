import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/models/todo.dart';

void main() {
  group('Todo Model', () {
    test('should serialize from JSON correctly', () {
      final json = {
        'id': 1,
        'title': 'Test Todo',
        'description': 'This is a test todo',
        'dueDate': '2025-05-10',
        'priority': 'High',
        'assignee': 'John Doe',
        'completed': false
      };

      final todo = Todo.fromJson(json);

      expect(todo.id, 1);
      expect(todo.title, 'Test Todo');
      expect(todo.description, 'This is a test todo');
      expect(todo.dueDate, '2025-05-10');
      expect(todo.priority, 'High');
      expect(todo.assignee, 'John Doe');
      expect(todo.completed, false);
    });

    test('should serialize to JSON correctly', () {
      final todo = Todo(
        id: 1,
        title: 'Test Todo',
        description: 'This is a test todo',
        dueDate: '2025-05-10',
        priority: 'High',
        assignee: 'John Doe',
        completed: false,
      );

      final json = todo.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Test Todo');
      expect(json['description'], 'This is a test todo');
      expect(json['dueDate'], '2025-05-10');
      expect(json['priority'], 'High');
      expect(json['assignee'], 'John Doe');
      expect(json['completed'], false);
    });

    test('should throw error for invalid JSON', () {
      final invalidJson = {
        'id': 'invalid_id',
        'title': null,
        'description': 12345,
        'dueDate': 'invalid_date',
        'priority': null,
        'assignee': 67890,
        'completed': 'not_a_boolean'
      };

      expect(() => Todo.fromJson(invalidJson), throwsA(isA<Exception>()));
    });
  });
}