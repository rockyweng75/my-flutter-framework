import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/mock/mock_notification_service.dart';
import 'dart:async';

void main() {
  group('MockNotificationService', () {
    late MockNotificationService mockNotificationService;
    late StreamSubscription<int> subscription;
    
    setUp(() {
      mockNotificationService = MockNotificationService();
    });

    tearDown(() async {
      await subscription.cancel();
      mockNotificationService.dispose();
    });

    test('should emit notification counts periodically', () async {
      final notificationCounts = <int>[];

      subscription = mockNotificationService.notificationCountStream.listen(notificationCounts.add);

      // 等待模擬通知的幾個週期
      await Future.delayed(Duration(seconds: 12));

      expect(notificationCounts.length, greaterThanOrEqualTo(2));
      expect(notificationCounts.every((count) => count >= 0 && count < 10), isTrue);
    });

    // test('should close the stream controller on dispose', () {
    //   mockNotificationService.dispose();

    //   expect(() => mockNotificationService._controller.add(1), throwsA(isA<StateError>()));
    // });
  });
}