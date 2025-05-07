import 'dart:convert';

class JsonHelper {
  static String mapToJson(Map<String, dynamic> map, {int indent = 2}) {
    return const JsonEncoder.withIndent('  ').convert(map);
  }
}