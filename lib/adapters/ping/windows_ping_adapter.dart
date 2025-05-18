import 'package:my_flutter_framework/adapters/ping/ping_adapter.dart';

class WindowsPingAdapter extends PingAdapter {

  @override
  String get pingCommand => 'ping';

  @override
  String get pingArgs => '-n';

  @override
  String get pingArgs2 => '1';

  @override
  RegExp get pingRegex => RegExp(r'time[=<]([0-9]+)ms');

}
