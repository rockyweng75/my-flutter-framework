import 'dart:math';
import 'package:my_flutter_framework/api/chat/i_chat_service.dart';
import 'package:my_flutter_framework/models/chat_message.dart';
import 'package:faker/faker.dart';

/// 用於開發與測試的 Mock 聊天服務
class MockChatService implements IChatService {
  final List<ChatMessage> _messages = [];
  final Random _random = Random();

  @override
  List<ChatMessage> get messages => _messages;

  @override
  Future<void> sendMessage(String message) async {
    final faker = Faker();
    final userMsg = ChatMessage(
      id: _random.nextInt(1000000).toString(),
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    // 模擬 AI 回覆延遲
    await Future.delayed(const Duration(milliseconds: 500));
    // 產生 50 句以上的內容，並隨機插入 markdown 語法與換行
    final markdownSamples = [
      '**${faker.lorem.word()}**',
      '_${faker.lorem.word()}_',
      '[${faker.lorem.word()}](https://example.com)',
      '```dart\nprint(\'Hello World!\');\n```',
      '- ${faker.lorem.sentence()}',
      '> ${faker.lorem.sentence()}',
      '`inline code`',
      '# ${faker.lorem.word()}',
      '1. ${faker.lorem.sentence()}',
    ];
    final sentences = List.generate(50, (i) {
      // 每 7 句插入一個 markdown 樣本並加換行
      if (i % 7 == 0) {
        return markdownSamples[_random.nextInt(markdownSamples.length)] + '\n';
      }
      // 其餘句子每 2 句加換行
      return faker.lorem.sentence() + ((i % 2 == 1) ? '\n' : ' ');
    });
    final aiContent = sentences.join('');
    final aiMsg = ChatMessage(
      id: _random.nextInt(1000000).toString(),
      text: aiContent,
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(aiMsg);
  }

  @override
  Future<String> receiveMessage() async {
    // 回傳最後一則 AI 訊息
    final aiMsg = _messages.lastWhere((m) => !m.isUser, orElse: () => ChatMessage(id: '', text: '無回覆', isUser: false, timestamp: DateTime.now()));
    return aiMsg.text;
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    _messages.removeWhere((m) => m.id == messageId);
  }
}