import 'dart:convert';
import 'package:http/http.dart' as http;
class MockHttpClient {
  /// Mock implementation of the send method for testing purposes with custom JSON string.
  Future<http.StreamedResponse> send(http.BaseRequest request, {String? customJsonString}) async {
    // Log the request details for debugging.
    print('Mock Request: ${request.method} ${request.url}');
    if (request.headers.isNotEmpty) {
      print('Headers: ${request.headers}');
    }
    if (request is http.Request && request.body.isNotEmpty) {
      print('Body: ${request.body}');
    }

    // Use the custom JSON string if provided, otherwise default to an empty body.
    final responseBody = customJsonString ?? '';

    // Return a mock response with a 200 status code and the custom or empty body.
    final mockResponse = http.StreamedResponse(
      Stream.value(utf8.encode(responseBody)),
      200,
      request: request,
    );

    return mockResponse;
  }
}