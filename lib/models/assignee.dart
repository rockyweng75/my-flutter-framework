import 'package:json_annotation/json_annotation.dart';

part 'assignee.g.dart';

@JsonSerializable()
class Assignee {
  final int id;
  final String name;

  Assignee({required this.id, required this.name});

  factory Assignee.fromJson(Map<String, dynamic> json) => _$AssigneeFromJson(json);

  Map<String, dynamic> toJson() => _$AssigneeToJson(this);
}