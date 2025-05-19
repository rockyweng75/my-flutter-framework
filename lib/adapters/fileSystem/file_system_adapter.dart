import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/adapters/fileSystem/mobile_file_system_adapter.dart';
import 'package:my_flutter_framework/adapters/fileSystem/web_file_system_adapter.dart';

/// 檔案儲存抽象介面
abstract class FileSystemAdapter {
  /// 儲存檔案，回傳儲存後的 key 或路徑
  Future<String> saveFile(String fileName, Uint8List bytes);

  /// 讀取檔案內容
  Future<Uint8List?> readFile(String key);

  /// 刪除檔案
  Future<void> deleteFile(String key);
}

final fileSystemAdapterProvider = Provider<FileSystemAdapter>((ref) {
  if (kIsWeb) {
    return WebFileSystemAdapter();
  } else {
    return MobileFileSystemAdapter();
  }
});
