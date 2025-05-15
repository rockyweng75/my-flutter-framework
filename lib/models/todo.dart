import 'package:json_annotation/json_annotation.dart';

part 'todo.g.dart';

@JsonSerializable()
class Todo {
  final int id;
  final String title; // 抬頭
  final DateTime startTime; // 開始時間
  final DateTime endTime; // 結束時間
  final String status; // 狀態
  final String? content; // 內容，可為空
  final String? location; // 地點，可為空
  final List<String>? attachments; // 附件，可為空
  final String? assignee; // 對象，可為空

  Todo({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.content,
    this.location,
    this.attachments,
    this.assignee,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    try {
      return Todo(
        id: json['id'] as int,
        title: json['title'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        status: json['status'] as String,
        content: json['content'] as String?,
        location: json['location'] as String?,
        attachments: (json['attachments'] as List<dynamic>?)?.cast<String>(),
        assignee: json['assignee'] as String?,
      );
    } catch (e) {
      throw Exception('Error parsing Todo JSON: \\${e.toString()}');
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'status': status,
    if (content != null) 'content': content,
    if (location != null) 'location': location,
    if (attachments != null) 'attachments': attachments,
    if (assignee != null) 'assignee': assignee,
  };
}