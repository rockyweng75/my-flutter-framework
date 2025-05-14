import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:file_selector/file_selector.dart';
import 'package:my_flutter_framework/shared/utils/image_compress_util.dart';
import 'package:flutter/services.dart';

class MockXFile extends XFile {
  final Uint8List _data;
  MockXFile(this._data, {String name = 'test.jpg'}) : super.fromData(_data, name: name, mimeType: 'image/jpeg');
  @override
  Future<Uint8List> readAsBytes() async => _data;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  /// flutter drive --driver integration_test/driver.dart --target integration_test/image_compress_util_integration_test.dart
  testWidgets('compressImageToTargetSize integration test', (WidgetTester tester) async {
    final assetPath = 'assets/images/image1.jpeg';
    final bytes = await rootBundle.load(assetPath);
    print('原圖大小: \\${(bytes.lengthInBytes / 1024).toStringAsFixed(1)} KB');
    final file = MockXFile(bytes.buffer.asUint8List(), name: 'image1.jpeg');
    final result = await ImageCompressUtil.compressImageToTargetSize(
      file,
      maxSizeBytes: 150 * 1024,
    );
    print('壓縮後大小: \\${(await result.length() / 1024).toStringAsFixed(1)} KB');
    expect(await result.length(), lessThanOrEqualTo(150 * 1024));
  }, timeout: Timeout(Duration(seconds: 60)));
}
