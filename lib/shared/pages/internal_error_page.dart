import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InternalErrorPage extends StatelessWidget {
  final String errorMessage;
  final String errorDescription;
  final String redirectPath;
  final String buttonText;

  const InternalErrorPage({
    super.key,
    this.errorMessage = '伺服器錯誤',
    this.redirectPath = '/',
    this.buttonText = '回首頁',
    this.errorDescription = '發生了未知的伺服器錯誤，請稍後再試。',
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
                  'assets/500.png', // 可替換為 500 專屬圖片
                  width: 200,
                  height: 400,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
