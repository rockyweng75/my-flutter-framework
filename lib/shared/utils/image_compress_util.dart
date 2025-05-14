import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:logger/logger.dart';

class ImageCompressUtil {
  /// 壓縮圖片直到小於 maxSizeBytes，回傳壓縮後的 XFile
  static Future<XFile> compressImageToTargetSize(
    XFile file, {
    int maxSizeBytes = 300 * 1024,
    int minQuality = 20,
  }) async {
    if (kIsWeb) {
      // web: 用 image 套件壓縮
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        Logger().e('Invalid image data: decodeImage failed.');
        return file;
      }
      int quality = 90;
      Uint8List jpg;
      int loopCount = 0;
      const int maxLoop = 10;
      do {
        jpg = Uint8List.fromList(img.encodeJpg(image, quality: quality));
        quality -= 10;
        loopCount++;
        if (loopCount > maxLoop) {
          Logger().e('Image compression loop exceeded maxLoop($maxLoop).');
          break;
        }
      } while (jpg.length > maxSizeBytes && quality >= minQuality);
      final now = DateTime.now();
      final name = 'web_image_${now.millisecondsSinceEpoch}.jpg';
      return XFile.fromData(jpg, name: name, mimeType: 'image/jpeg');
    } else {
      // mobile/desktop: 用 flutter_image_compress
      int quality = 90;
      Uint8List result;
      final bytes = await file.readAsBytes();
      try {
        do {
          result = Uint8List.fromList(
            await FlutterImageCompress.compressWithList(
              bytes,
              quality: quality,
              format: CompressFormat.jpeg,
            ),
          );
          quality -= 10;
        } while (result.length > maxSizeBytes && quality >= minQuality);
        return XFile.fromData(result, name: file.name, mimeType: 'image/jpeg');
      } on UnsupportedError catch (_) {
        // 不支援時直接回傳原圖（包含 UnimplementedError）
        Logger().e('Image compression not supported on this platform.');
        return file;
      }
    }
  }
}
