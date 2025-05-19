import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:my_flutter_framework/adapters/fileSystem/web_file_system_adapter.dart';

/// 通用圖片預覽元件，支援本地、網路、IndexedDB 圖片
class ImagePreview extends StatelessWidget {
  final String fileName;
  final double height;
  const ImagePreview({super.key, required this.fileName, this.height = 80});

  bool get isImage => fileName.endsWith('.png') ||
      fileName.endsWith('.jpg') ||
      fileName.endsWith('.jpeg') ||
      fileName.endsWith('.gif') ||
      fileName.startsWith('idb://');

  @override
  Widget build(BuildContext context) {
    if (!isImage) return const SizedBox.shrink();
    Widget preview;
    if (fileName.startsWith('http://') || fileName.startsWith('https://')) {
      preview = Image.network(
        fileName,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
      );
    } else if (fileName.startsWith('/') || fileName.startsWith('file://')) {
      preview = Image.file(
        fileName.startsWith('file://') ? File(fileName.substring(7)) : File(fileName),
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
      );
    } else if (kIsWeb && fileName.startsWith('idb://')) {
      preview = FutureBuilder<Uint8List?>(
        future: _loadIndexedDbImage(fileName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(height: height, child: const Center(child: CircularProgressIndicator(strokeWidth: 2)));
          }
          if (snapshot.hasData && snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              height: height,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
            );
          }
          return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
        },
      );
    } else {
      return const SizedBox.shrink();
    }
    // 包一層 GestureDetector，Web 需支援滑鼠游標與 hover 效果
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: kIsWeb ? (event) => _onHover(context, true) : null,
        onExit: kIsWeb ? (event) => _onHover(context, false) : null,
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  backgroundColor: Colors.black,
                  insetPadding: const EdgeInsets.all(12),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5,
                    child: _buildFullImage(context),
                  ),
                );
              },
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: kIsWeb && _isHovered(context)
                ? BoxDecoration(boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.15), blurRadius: 8)])
                : null,
            child: preview,
          ),
        ),
      ),
    );
  }

  Widget _buildFullImage(BuildContext context) {
    if (fileName.startsWith('http://') || fileName.startsWith('https://')) {
      return Image.network(
        fileName,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80, color: Colors.grey),
      );
    } else if (fileName.startsWith('/') || fileName.startsWith('file://')) {
      return Image.file(
        fileName.startsWith('file://') ? File(fileName.substring(7)) : File(fileName),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80, color: Colors.grey),
      );
    } else if (kIsWeb && fileName.startsWith('idb://')) {
      return FutureBuilder<Uint8List?>(
        future: _loadIndexedDbImage(fileName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          if (snapshot.hasData && snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80, color: Colors.grey),
            );
          }
          return const Icon(Icons.broken_image, size: 80, color: Colors.grey);
        },
      );
    }
    return const SizedBox.shrink();
  }

  Future<Uint8List?> _loadIndexedDbImage(String idbPath) async {
    if (!kIsWeb) return null;
    try {
      final adapter = WebFileSystemAdapter();
      return await adapter.readFile(idbPath);
    } catch (e) {
      return null;
    }
  }

  // Web hover 狀態管理（用 InheritedWidget 方式簡單實作，StatelessWidget 內部 workaround）
  static final Map<Element, bool> _hoverMap = {};
  void _onHover(BuildContext context, bool hover) {
    _hoverMap[context as Element] = hover;
    context.markNeedsBuild();
  }
  bool _isHovered(BuildContext context) => _hoverMap[context as Element] == true;
}
