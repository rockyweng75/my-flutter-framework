import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'file_system_adapter.dart';

/// Android/iOS 實作：儲存於 app documents directory
class MobileFileSystemAdapter implements FileSystemAdapter {
  @override
  Future<String> saveFile(String fileName, Uint8List bytes) async {
    if (kIsWeb) throw UnsupportedError('Not supported on web');
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  @override
  Future<Uint8List?> readFile(String key) async {
    if (kIsWeb) throw UnsupportedError('Not supported on web');
    final file = File(key);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }

  @override
  Future<void> deleteFile(String key) async {
    if (kIsWeb) throw UnsupportedError('Not supported on web');
    final file = File(key);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
