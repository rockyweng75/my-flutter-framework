import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/database/todo_repository.dart';
import 'package:my_flutter_framework/models/todo.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final testDir = Directory.systemTemp.createTempSync();
    Hive.init(testDir.path);
    // await HiveRepository.openBox('testBox');
  });

  group('TodoRepository', () {
    final testTodo = Todo(
      id: 1,
      title: 'Test Todo',
      startTime: DateTime.parse('2025-05-14T09:00:00'),
      endTime: DateTime.parse('2025-05-14T10:00:00'),
      status: 'open',
      content: 'Test Content',
      location: 'Taipei',
      attachments: ['file1.png', 'file2.pdf'],
      assignee: 'tester',
    );

    test('upsertTodo and getTodo', () async {
      await TodoRepository.upsertTodo(testTodo);
      final fetched = await TodoRepository.getTodo(testTodo.id);
      expect(fetched, isNotNull);
      expect(fetched!.title, equals(testTodo.title));
      expect(fetched.content, equals(testTodo.content));
      expect(fetched.location, equals(testTodo.location));
      expect(fetched.attachments, equals(testTodo.attachments));
      expect(fetched.assignee, equals(testTodo.assignee));
    });

    test('getAllTodos', () async {
      await TodoRepository.upsertTodo(testTodo);
      final todos = await TodoRepository.getAllTodos(keyword: 'Test');
      expect(todos.any((t) => t.id == testTodo.id), isTrue);
    });

    test('deleteTodo', () async {
      await TodoRepository.upsertTodo(testTodo);
      await TodoRepository.deleteTodo(testTodo.id);
      final deleted = await TodoRepository.getTodo(testTodo.id);
      expect(deleted, isNull);
    });

    test('getAllTodos with filter', () async {
      final todo2 = Todo(
        id: 2,
        title: 'Meeting',
        startTime: DateTime.parse('2025-05-15T09:00:00'),
        endTime: DateTime.parse('2025-05-15T10:00:00'),
        status: 'done',
        content: null,
        location: 'Kaohsiung',
        attachments: null,
        assignee: null,
      );
      await TodoRepository.upsertTodo(todo2);
      final filtered = await TodoRepository.getAllTodos(
        startDate: DateTime.parse('2025-05-15T00:00:00'),
        endDate: DateTime.parse('2025-05-15T23:59:59'),
        location: 'Kaohsiung',
        status: 'done',
      );
      expect(filtered.length, 1);
      expect(filtered.first.id, 2);
    });

    test('addTodo should auto-increment id and save todo', () async {
      final todo = Todo(
        id: 0, // id 會被忽略
        title: 'Auto ID Todo',
        startTime: DateTime.parse('2025-05-16T09:00:00'),
        endTime: DateTime.parse('2025-05-16T10:00:00'),
        status: 'open',
        content: 'Auto id test',
        location: 'Tainan',
        attachments: null,
        assignee: null,
      );
      final newTodo = await TodoRepository.addTodo(todo);
      expect(newTodo.id, greaterThan(0));
      final fetched = await TodoRepository.getTodo(newTodo.id);
      expect(fetched, isNotNull);
      expect(fetched!.title, equals('Auto ID Todo'));
      expect(fetched.content, equals('Auto id test'));
    });
  });
}
