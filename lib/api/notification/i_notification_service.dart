
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/api/notification/notification_service.dart';
import 'package:my_flutter_framework/mock/mock_notification_service.dart';

final notificationServiceProvider = Provider<INotificationService>((ref) {
  if(kDebugMode) {
    return MockNotificationService(); // 使用模擬服務
  }
  return NotificationService();
});

abstract class INotificationService {
  Stream<int> get notificationCountStream;
}
