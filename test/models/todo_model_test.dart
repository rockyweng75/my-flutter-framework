import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/models/todo.dart';

void main() {
  group('Todo Model', () {
    test('should serialize from JSON correctly', () {
      final json = {
        'id': 1,
        'title': 'Test Todo',
        'startTime': '2025-05-10T09:00:00',
        'endTime': '2025-05-10T10:00:00',
        'status': 'open',
        'content': 'This is a test todo',
        'location': 'Taipei',
        'attachments': ['file1.png', 'file2.pdf'],
        'assignee': 'John Doe',
      };

      final todo = Todo.fromJson(json);

      expect(todo.id, 1);
      expect(todo.title, 'Test Todo');
      expect(todo.startTime, DateTime.parse('2025-05-10T09:00:00'));
      expect(todo.endTime, DateTime.parse('2025-05-10T10:00:00'));
      expect(todo.status, 'open');
      expect(todo.content, 'This is a test todo');
      expect(todo.location, 'Taipei');
      expect(todo.attachments, ['file1.png', 'file2.pdf']);
      expect(todo.assignee, 'John Doe');
    });

    test('should serialize to JSON correctly', () {
      final todo = Todo(
        id: 1,
        title: 'Test Todo',
        startTime: DateTime.parse('2025-05-10T09:00:00'),
        endTime: DateTime.parse('2025-05-10T10:00:00'),
        status: 'open',
        content: 'This is a test todo',
        location: 'Taipei',
        attachments: ['file1.png', 'file2.pdf'],
        assignee: 'John Doe',
      );

      final json = todo.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Test Todo');
      expect(json['startTime'], '2025-05-10T09:00:00.000');
      expect(json['endTime'], '2025-05-10T10:00:00.000');
      expect(json['status'], 'open');
      expect(json['content'], 'This is a test todo');
      expect(json['location'], 'Taipei');
      expect(json['attachments'], ['file1.png', 'file2.pdf']);
      expect(json['assignee'], 'John Doe');
    });

    test('should throw error for invalid JSON', () {
      final invalidJson = {
        'id': 'invalid_id',
        'title': null,
        'startTime': 'invalid_date',
        'endTime': 'invalid_date',
        'status': null,
      };

      expect(() => Todo.fromJson(invalidJson), throwsA(isA<Exception>()));
    });
  });
}