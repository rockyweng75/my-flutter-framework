import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/api/ai_client.dart';
import 'package:my_flutter_framework/api/chat/chat_service.dart';
import 'package:my_flutter_framework/mock/mock_chat_service.dart';
import 'package:my_flutter_framework/models/chat_message.dart';

final chatServiceProvider = Provider<IChatService>((ref) {
  // 判斷是否為測試環境
  if (kDebugMode) {
    return MockChatService();
  } else {
    final aiClient = ref.read(aiClientProvider);
    return ChatService(aiClient: aiClient);
  }
});

abstract class IChatService {
  Future<void> sendMessage(String message);
  Future<String> receiveMessage();
  Future<void> deleteMessage(String messageId);
  // 新增：取得所有訊息
  List<ChatMessage> get messages;
}