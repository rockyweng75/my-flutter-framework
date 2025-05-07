import 'package:my_flutter_framework/api/notification/i_notification_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


class NotificationService extends INotificationService {
  late final WebSocketChannel _channel;

  NotificationService() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:3000/notifications'),
    );
  }
  
  @override
  Stream<int> get notificationCountStream => _channel.stream.map((event) {
        final data = int.tryParse(event) ?? 0;
        return data;
      });

  void dispose() {
    _channel.sink.close();
  }
}