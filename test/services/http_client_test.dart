import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/api/http_client.dart';
import 'package:http/http.dart' as http;

void main() {
  final client = HttpClient('https://jsonplaceholder.typicode.com');

  group('HttpClient Tests with JSONPlaceholder', () {
    test('GET /posts/1 with parsing', () async {
      final response = await client.get<Map<String, dynamic>>('/posts/1', fromJson: (json) => json as Map<String, dynamic>);
      expect(response['id'], 1);
      expect(response['userId'], isNotNull);
    });

    test('POST /posts with parsing', () async {
      final response = await client.post<Map<String, dynamic>>('/posts',
          body: {
            'title': 'foo',
            'body': 'bar',
            'userId': 1,
          },
          fromJson: (json) => json as Map<String, dynamic>);
      expect(response['id'], isNotNull);
    });

    test('PUT /posts/1 with parsing', () async {
      final response = await client.put<Map<String, dynamic>>('/posts/1',
          body: {
            'id': 1,
            'title': 'foo',
            'body': 'bar',
            'userId': 1,
          },
          fromJson: (json) => json as Map<String, dynamic>);
      expect(response['id'], 1);
      expect(response['title'], 'foo');
    });

    test('DELETE /posts/1 with parsing', () async {
      final response = await client.delete<Map<String, dynamic>>('/posts/1', fromJson: (json) => json as Map<String, dynamic>);
      expect(response, isEmpty);
    });

    test('GET /invalid-endpoint should throw FormatException', () async {
      expect(
        () async => await client.get<Map<String, dynamic>>('/invalid-endpoint', fromJson: (json) => json as Map<String, dynamic>),
        throwsA(isA<http.ClientException>()),
      );
    });
  });
}