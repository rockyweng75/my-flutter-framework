import 'dart:typed_data';
import 'package:my_flutter_framework/adapters/fileSystem/file_system_adapter.dart';

class WebFileSystemAdapter implements FileSystemAdapter {
  @override
  Future<String> saveFile(String fileName, Uint8List bytes) async {
    if (fileName.startsWith('blob:')) {
      throw UnsupportedError('WebFileSystemAdapter: blob: 檔案僅支援於 web 平台');
    }
    throw UnsupportedError('WebFileSystemAdapter is only available on web');
  }

  @override
  Future<Uint8List?> readFile(String key) async {
    throw UnsupportedError('WebFileSystemAdapter is only available on web');
  }

  @override
  Future<void> deleteFile(String key) async {
    throw UnsupportedError('WebFileSystemAdapter is only available on web');
  }
}
