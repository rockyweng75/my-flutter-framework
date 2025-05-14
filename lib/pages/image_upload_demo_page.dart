import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/pages/layout/main_layout_page.dart';
import 'package:my_flutter_framework/shared/components/image_upload.dart';

class ImageUploadDemoPage extends ConsumerStatefulWidget {
  const ImageUploadDemoPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ImageUploadDemoPageState();
}

class _ImageUploadDemoPageState extends MainLayoutPage<ImageUploadDemoPage> {
  @override
  Widget buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '圖片上傳元件展示',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ImageUpload(
            label: '選擇或拍攝圖片',
            onImageSelected: (file) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已選擇圖片: \\${file.name}')),
              );
            },
            isDebug: true,
          ),
        ],
      ),
    );
  }
}
