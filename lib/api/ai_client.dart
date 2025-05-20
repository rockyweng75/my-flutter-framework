import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/api/http_client.dart';

final aiClientProvider = Provider<AiClient>((ref) {
  // 取回env的baseUrl
  final baseUrl = 'http://localhost:3000';
  final key = 'your_api_key';
  return AiClient(baseUrl, key);
});

class AiClient extends HttpClient {
  AiClient(super.baseUrl, key) : super(
    defaultHeaders: {
      'Authorization': 'Bearer $key',
      'Content-Type': 'application/json',
    }
  );
}