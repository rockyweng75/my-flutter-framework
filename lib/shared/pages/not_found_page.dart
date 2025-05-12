import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_framework/shared/pages/balloon_shooting_game_page.dart';

class NotFoundPage extends StatelessWidget {
  final String errorMessage;
  final String errorDescription;
  final String redirectPath;
  final String buttonText;

  const NotFoundPage({
    super.key,
    this.errorMessage = '找不到頁面',
    this.redirectPath = '/',
    this.buttonText = '回首頁',
    this.errorDescription = '您請求的頁面不存在。',
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 232, 221),
      body: Center(
        child: Scrollbar(
          thumbVisibility: true,
          controller: scrollController,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/404.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    context.go(redirectPath);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: Text(buttonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  errorMessage,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  errorDescription,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                // 小遊戲區塊（直接嵌入，不跳頁）
                SizedBox(
                  width: 340,
                  height: 420,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BalloonShootingGameEmbed(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 於檔案底部新增嵌入版小遊戲元件
class BalloonShootingGameEmbed extends StatefulWidget {
  const BalloonShootingGameEmbed({super.key});

  @override
  State<BalloonShootingGameEmbed> createState() =>
      _BalloonShootingGameEmbedState();
}

class _BalloonShootingGameEmbedState extends State<BalloonShootingGameEmbed> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BalloonShootingGamePage(key: const ValueKey('embed')),
    );
  }
}
