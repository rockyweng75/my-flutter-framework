import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

final httpClientProvider = Provider<HttpClient>((ref) {
  // 取回env的baseUrl
  final baseUrl = 'http://localhost:3000'; // Replace with your base URL
  return HttpClient(baseUrl);
});

class HttpLoggerClient extends http.BaseClient {
  final http.Client _inner;
  final Logger _logger = Logger();

  HttpLoggerClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.addAll({'Content-type': 'application/json; charset=UTF-8'});
    _logger.i('Request: ${request.method} ${request.url}');
    if (request.headers.isNotEmpty) {
      _logger.i('Headers: ${request.headers}');
    }
    if (request is http.Request && request.body.isNotEmpty) {
      _logger.i('Body: ${request.body}');
    }

    final response = await _inner.send(request);

    _logger.i('Response: ${response.statusCode} ${response.reasonPhrase}');
    return response;
  }
}

class HttpClient {
  final String baseUrl;
  final http.Client _client;
  final Map<String, String> _defaultHeaders = {};

  /// Creates an instance of [HttpClient] with the given [baseUrl] and optional [defaultHeaders].
  ///
  /// [baseUrl] is the base URL for all HTTP requests.
  /// [defaultHeaders] are the headers that will be included in every request by default.
  HttpClient(this.baseUrl, {Map<String, String>? defaultHeaders}) 
      : _client = HttpLoggerClient(http.Client()) {
    if (defaultHeaders != null) {
      _defaultHeaders.addAll(defaultHeaders);
    }
  }

  String get apiKey => _defaultHeaders['Authorization']?.replaceFirst('Bearer ', '') ?? '';
  Map<String, String> get defaultHeaders => _defaultHeaders;

  /// Sends a GET request to the specified [endpoint].
  ///
  /// [headers] are optional headers to include in the request.
  /// [fromJson] is an optional function to parse the response body.
  Future<T> get<T>(String endpoint, {Map<String, String>? headers, T Function(dynamic)? fromJson}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await _client.get(url, headers: _mergeHeaders(headers));
    return _processResponse(response, fromJson);
  }

  /// Sends a POST request to the specified [endpoint].
  ///
  /// [headers] are optional headers to include in the request.
  /// [body] is the request payload to send.
  /// [fromJson] is an optional function to parse the response body.
  Future<T> post<T>(String endpoint, {Map<String, String>? headers, Object? body, T Function(dynamic)? fromJson}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await _client.post(url, headers: _mergeHeaders(headers), body: jsonEncode(body));
    return _processResponse(response, fromJson);
  }

  /// Sends a PUT request to the specified [endpoint].
  ///
  /// [headers] are optional headers to include in the request.
  /// [body] is the request payload to send.
  /// [fromJson] is an optional function to parse the response body.
  Future<T> put<T>(String endpoint, {Map<String, String>? headers, Object? body, T Function(dynamic)? fromJson}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await _client.put(url, headers: _mergeHeaders(headers), body: jsonEncode(body));
    return _processResponse(response, fromJson);
  }

  /// Sends a DELETE request to the specified [endpoint].
  ///
  /// [headers] are optional headers to include in the request.
  /// [fromJson] is an optional function to parse the response body.
  Future<T> delete<T>(String endpoint, {Map<String, String>? headers, T Function(dynamic)? fromJson}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await _client.delete(url, headers: _mergeHeaders(headers));
    return _processResponse(response, fromJson);
  }

  /// Merges the default headers with the provided [headers].
  ///
  /// If [headers] is null, only the default headers are returned.
  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    return {..._defaultHeaders, if (headers != null) ...headers};
  }

  /// Processes the HTTP [response] and parses it using the [fromJson] function if provided.
  ///
  /// Throws a [FormatException] if the response body cannot be parsed.
  /// Throws a [http.ClientException] if the response status code indicates an error.
  T _processResponse<T>(http.Response response, T Function(dynamic)? fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decodedBody = jsonDecode(response.body);
        if (fromJson != null) {
          return fromJson(decodedBody);
        } else {
          return decodedBody as T;
        }
      } catch (e) {
        throw FormatException('Failed to parse response body: ${response.body}', e);
      }
    } else {
      throw http.ClientException('Failed request: ${response.statusCode} ${response.reasonPhrase}', response.request?.url);
    }
  }
}