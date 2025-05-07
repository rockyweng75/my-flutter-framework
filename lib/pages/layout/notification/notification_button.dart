import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/pages/layout/notification/notification_handler.dart';
import 'package:my_flutter_framework/api/notification/i_notification_service.dart';
import 'dart:async'; // 引入 dart:async 用於 StreamSubscription

class NotificationButton extends ConsumerStatefulWidget {
  const NotificationButton({super.key});

  @override
  _NotificationButtonState createState() => _NotificationButtonState();
}

class _NotificationButtonState extends ConsumerState<NotificationButton> {
  int unreadCount = 0;
  late StreamSubscription<int> _subscription; // 保存訂閱的引用

  @override
  void initState() {
    super.initState();
    _subscribeToUnreadCount();
  }

  void _subscribeToUnreadCount() {
    final notificationService = ref.read(notificationServiceProvider);
    _subscription = notificationService.notificationCountStream.listen((count) {
      if (mounted) { // 確保 State 仍然掛載在樹中
        setState(() {
          unreadCount = count;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel(); // 取消訂閱以避免記憶體洩漏
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0), // 增加右側的間距
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              NotificationHandler.showNotification(context);
            },
          ),
          if (unreadCount > 0)
            Positioned(
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  unreadCount > 9 ? 'M' : '$unreadCount', // 顯示最多個位數，超過顯示 "M"
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}