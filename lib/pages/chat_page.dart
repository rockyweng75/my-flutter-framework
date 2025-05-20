import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:my_flutter_framework/api/chat/i_chat_service.dart';
import 'package:my_flutter_framework/models/chat_message.dart';


class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  late final IChatService _chatService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 取得 chatServiceProvider
    _chatService = ProviderScope.containerOf(context, listen: false).read(chatServiceProvider);
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    _controller.clear();
    try {
      await _chatService.sendMessage(text);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _chatService.messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: 'AI 回覆失敗: $e',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  Future<void> _deleteMessage(int index) async {
    final msg = _chatService.messages[index];
    setState(() {
      _isLoading = true;
    });
    try {
      await _chatService.deleteMessage(msg.id);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // 可選：顯示錯誤訊息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('刪除訊息失敗: $e')),
      );
    }
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 聊天室')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _chatService.messages.length,
              itemBuilder: (context, index) {
                final msg = _chatService.messages[index];
                return GestureDetector(
                  onLongPress: () => _deleteMessage(index),
                  child: Align(
                    alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 2),
                          child: Text(
                            msg.isUser ? '你' : 'AI',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[700]),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: msg.isUser ? Colors.blue[200] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: MarkdownBody(
                            data: msg.text,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 6),
                          child: Text(
                            _formatTime(msg.timestamp),
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: '輸入訊息...'
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
