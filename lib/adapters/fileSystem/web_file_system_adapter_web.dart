import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:async';
import 'package:my_flutter_framework/adapters/fileSystem/file_system_adapter.dart';

// Web 實作：使用 IndexedDB
class WebFileSystemAdapter implements FileSystemAdapter {
  static const String dbName = 'attachments_db';
  static const String storeName = 'files';

  Future<dynamic> _openDb() async {
    final completer = Completer<dynamic>();
    final request = html.window.indexedDB!.open(
      dbName,
      version: 1,
      onUpgradeNeeded: (e) {
        final db = (e.target as dynamic).result;
        if (!db.objectStoreNames!.contains(storeName)) {
          db.createObjectStore(storeName);
        }
      },
    );
    request
        .then((db) {
          completer.complete(db);
        })
        .catchError((e) {
          completer.completeError(e);
        });
    return completer.future;
  }

  @override
  Future<String> saveFile(String fileName, Uint8List bytes) async {
    if (!kIsWeb) throw UnsupportedError('Only supported on web');
    // blob: 處理
    if (fileName.startsWith('blob:')) {
      // 取得 blob url 對應的 bytes
      try {
        final req = await html.HttpRequest.request(
          fileName,
          responseType: 'arraybuffer',
        );
        final buffer = req.response as ByteBuffer;
        final realFileName = DateTime.now().millisecondsSinceEpoch.toString();
        final db = await _openDb();
        final txn = db.transaction(storeName, 'readwrite');
        final store = txn.objectStore(storeName);
        await store.put(Uint8List.view(buffer), realFileName);
        await txn.completed;
        return 'idb://$realFileName';
      } catch (e) {
        throw Exception('Failed to save blob file: $e');
      }
    }
    // 一般檔案
    final db = await _openDb();
    final txn = db.transaction(storeName, 'readwrite');
    final store = txn.objectStore(storeName);
    await store.put(bytes, fileName);
    await txn.completed;
    return 'idb://$fileName';
  }

  @override
  Future<Uint8List?> readFile(String key) async {
    if (!kIsWeb) throw UnsupportedError('Only supported on web');
    final db = await _openDb();
    final txn = db.transaction(storeName, 'readonly');
    final store = txn.objectStore(storeName);
    final fileName = key.replaceFirst('idb://', '');
    final result = await store.getObject(fileName);
    if (result is Uint8List) {
      return result;
    }
    if (result is List<int>) {
      return Uint8List.fromList(result);
    }
    if (result is ByteBuffer) {
      return Uint8List.view(result);
    }
    return null;
  }

  @override
  Future<void> deleteFile(String key) async {
    if (!kIsWeb) throw UnsupportedError('Only supported on web');
    final db = await _openDb();
    final txn = db.transaction(storeName, 'readwrite');
    final store = txn.objectStore(storeName);
    final fileName = key.replaceFirst('idb://', '');
    await store.delete(fileName);
    await txn.completed;
  }
}
