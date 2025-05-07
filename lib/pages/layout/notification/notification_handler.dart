import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/api/notification/i_notification_service.dart';

class NotificationHandler {
  static Future<int> getUnreadCount(WidgetRef ref) async {
    final notificationService = ref.read(notificationServiceProvider);
    return await notificationService.notificationCountStream.first;
  }

  static void showNotification(BuildContext context) {
    final snackBar = SnackBar(
      content: const Text('This is a notification!'),
      action: SnackBarAction(
        label: 'Dismiss',
        onPressed: () {},
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}