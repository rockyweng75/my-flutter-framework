// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Todo _$TodoFromJson(Map<String, dynamic> json) => Todo(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: json['status'] as String,
      content: json['content'] as String?,
      location: json['location'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      assignee: json['assignee'] as String?,
    );

Map<String, dynamic> _$TodoToJson(Todo instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'status': instance.status,
      'content': instance.content,
      'location': instance.location,
      'attachments': instance.attachments,
      'assignee': instance.assignee,
    };
