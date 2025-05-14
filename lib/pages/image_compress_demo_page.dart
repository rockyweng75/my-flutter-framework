import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/pages/layout/main_layout_page.dart';
import 'package:my_flutter_framework/shared/utils/image_compress_util.dart';
import 'package:my_flutter_framework/shared/utils/transaction_manager.dart';
import 'package:flutter/foundation.dart';

class ImageCompressDemoPage extends ConsumerStatefulWidget {
  const ImageCompressDemoPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ImageCompressDemoPageState();
}

class _ImageCompressDemoPageState
    extends MainLayoutPage<ImageCompressDemoPage> {
  XFile? _originalFile;
  XFile? _compressedFile;
  int? _originalSize;
  int? _compressedSize;
  Uint8List? _originalBytes;
  Uint8List? _compressedBytes;

  // 將壓縮邏輯獨立成靜態方法，方便 isolate/compute 使用
  static Future<Map<String, dynamic>> compressImageTask(Map<String, dynamic> args) async {
    final String filePath = args['filePath'] as String;
    final int maxSizeBytes = args['maxSizeBytes'] as int;
    final XFile file = XFile(filePath);
    final compressedFile = await ImageCompressUtil.compressImageToTargetSize(
      file,
      maxSizeBytes: maxSizeBytes,
    );
    final compressedBytes = await compressedFile.readAsBytes();
    return {
      'file': compressedFile,
      'size': compressedBytes.length,
      'bytes': compressedBytes,
    };
  }

  Future<void> _pickAndCompressImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final originalBytes = await pickedFile.readAsBytes();
    setState(() {
      _originalFile = pickedFile;
      _originalSize = originalBytes.length;
      _originalBytes = originalBytes;
      _compressedFile = null;
      _compressedSize = null;
      _compressedBytes = null;
    });
    if (mounted) {
      // 使用 compute 將壓縮任務丟到 isolate 執行，避免主執行緒卡頓
      final compressed = await TransactionManager(context).execute(() async {
        return await compute(
          compressImageTask,
          {
            'filePath': pickedFile.path,
            'maxSizeBytes': 100 * 1024,
          },
        );
      });
      if (compressed != null) {
        setState(() {
          _compressedFile = compressed['file'] as XFile;
          _compressedSize = compressed['size'] as int;
          _compressedBytes = compressed['bytes'] as Uint8List;
        });
      }
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _pickAndCompressImage,
              child: const Text('選擇並壓縮圖片'),
            ),
            const SizedBox(height: 24),
            ImageInfoBlock(label: '原始圖片', file: _originalFile, size: _originalSize, bytes: _originalBytes),
            ImageInfoBlock(label: '壓縮後圖片', file: _compressedFile, size: _compressedSize, bytes: _compressedBytes),
          ],
        ),
      ),
    );
  }
}

class ImageInfoBlock extends StatelessWidget {
  final String label;
  final XFile? file;
  final int? size;
  final Uint8List? bytes;

  const ImageInfoBlock({
    super.key,
    required this.label,
    required this.file,
    required this.size,
    required this.bytes,
  });

  @override
  Widget build(BuildContext context) {
    if (file == null || size == null || bytes == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label (${(size! / 1024).toStringAsFixed(1)} KB)'),
        const SizedBox(height: 8),
        Image(
          image: MemoryImage(bytes!),
          key: ValueKey(bytes!.length),
          width: 200,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
