import 'package:my_flutter_framework/api/ai_client.dart';
import 'package:my_flutter_framework/api/chat/i_chat_service.dart';
import 'package:my_flutter_framework/models/chat_message.dart';

/// AI 聊天服務，負責與 AI 機器人 API 溝通
class ChatService implements IChatService {
  final AiClient aiClient;
  // 新增訊息快取（如需同步後端可改為 API 取得）
  final List<ChatMessage> _messages = [];

  ChatService({required this.aiClient});

  @override
  List<ChatMessage> get messages => _messages;

  /// 發送訊息給 AI，取得回覆
  @override
  Future<void> sendMessage(String message) async {
    _messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    try {
      // Azure OpenAI 聊天 API 格式
      final data = await aiClient.post(
        'chat/completions?api-version=2023-03-15-preview', // 或你指定的 api-version
        body: {
          'messages': [
            {'role': 'user', 'content': message}
          ],
          'max_tokens': 256,
          'temperature': 0.7,
        },
      );
      // 回傳格式為 {choices: [{message: {content: ...}}]}
      final aiReply = (data['choices'] != null && data['choices'].isNotEmpty)
          ? data['choices'][0]['message']['content']?.toString() ?? '無回覆'
          : '無回覆';
      _messages.add(
        ChatMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          text: aiReply,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      _messages.add(
        ChatMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
          text: 'AI 回覆失敗: $e',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<String> receiveMessage() async {
    // 回傳最後一則 AI 訊息
    final aiMsg = _messages.lastWhere(
      (m) => !m.isUser,
      orElse:
          () => ChatMessage(
            id: '',
            text: '無回覆',
            isUser: false,
            timestamp: DateTime.now(),
          ),
    );
    return aiMsg.text;
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    _messages.removeWhere((m) => m.id == messageId);
  }
}
