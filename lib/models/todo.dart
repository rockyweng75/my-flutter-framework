import 'package:json_annotation/json_annotation.dart';

part 'todo.g.dart';

@JsonSerializable()
class Todo {
  final int id;
  final String title;
  final String description;
  final String dueDate;
  final String priority;
  final String assignee;
  final bool completed;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.assignee,
    required this.completed,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    try {
      if (json['id'] is! int ||
          json['title'] is! String ||
          json['description'] is! String ||
          json['dueDate'] is! String ||
          json['priority'] is! String ||
          json['assignee'] is! String ||
          json['completed'] is! bool) {
        throw Exception('Invalid JSON format for Todo');
      }
      return _$TodoFromJson(json);
    } catch (e) {
      throw Exception('Error parsing Todo JSON: ${e.toString()}');
    }
  }

  Map<String, dynamic> toJson() => _$TodoToJson(this);
}