import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/api/notification/i_notification_service.dart';

final mockNotificationServiceProvider = Provider<MockNotificationService>((ref) {
  return MockNotificationService();
});

class MockNotificationService extends INotificationService {
  final StreamController<int> _controller = StreamController<int>.broadcast();

  MockNotificationService() {
    _simulateNotifications();
  }

  @override
  Stream<int> get notificationCountStream => _controller.stream;

  void _simulateNotifications() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      final randomNotificationCount = DateTime.now().second % 10; // 模擬通知數量
      _controller.add(randomNotificationCount);
    });
  }

  void dispose() {
    _controller.close();
  }
}