import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:my_flutter_framework/styles/app_color.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:my_flutter_framework/adapters/fileSystem/web_file_system_adapter.dart';

class FileUpload extends StatefulWidget {
  final void Function(XFile file)? onFileSelected;
  final String? label;
  final String? accept;
  final bool allowMultiple;
  final Color? backgroundColor;
  final bool enabled;
  final String? initialValue;

  const FileUpload({
    super.key,
    this.onFileSelected,
    this.label,
    this.accept,
    this.allowMultiple = false,
    this.backgroundColor,
    this.enabled = true,
    this.initialValue,
  });

  @override
  State<FileUpload> createState() => _FileUploadState();
}

class _FileUploadState extends State<FileUpload> {
  String? _fileName;
  bool _isLoading = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    // 若 initialValue 有值，預設顯示檔名
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _fileName = widget.initialValue;
    }
  }

  Future<void> _pickFile() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final typeGroups = (widget.accept != null && widget.accept!.isNotEmpty)
          ? [XTypeGroup(extensions: widget.accept!.split(',').map((e) => e.trim()).toList())]
          : <XTypeGroup>[];
      List<XFile> files = [];
      if (widget.allowMultiple) {
        files = await openFiles(acceptedTypeGroups: typeGroups);
      } else {
        final file = await openFile(acceptedTypeGroups: typeGroups);
        if (file != null) files = [file];
      }
      if (files.isNotEmpty) {
        setState(() {
          _fileName = files.first.name;
        });
        if (widget.onFileSelected != null) {
          widget.onFileSelected!(files.first);
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 僅供測試用：設定檔名
  void setFileNameForTest(String? name) {
    setState(() {
      _fileName = name;
    });
  }

  // Web: 讀取 IndexedDB 圖片
  Future<Uint8List?> _loadIndexedDbImage(String idbPath) async {
    if (!kIsWeb) return null;
    try {
      // 動態 import，避免非 web 編譯錯誤
      // ignore: avoid_web_libraries_in_flutter
      // ignore: import_of_legacy_library_into_null_safe
      // ignore: undefined_prefixed_name
      final adapter = WebFileSystemAdapter();
      return await adapter.readFile(idbPath);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = _fileName != null && _fileName!.isNotEmpty;
    final isEnabled = widget.enabled;
    // 新增：debug log，協助追蹤 imagePreview 判斷
    debugPrint('FileUpload: _fileName=$_fileName, hasFile=$hasFile');
    Widget? imagePreview;
    if (hasFile && (
        _fileName!.endsWith('.png') ||
        _fileName!.endsWith('.jpg') ||
        _fileName!.endsWith('.jpeg') ||
        _fileName!.endsWith('.gif') ||
        _fileName!.startsWith('idb://')
      )) {
      debugPrint('FileUpload: 進入圖片預覽判斷, _fileName=$_fileName');
      if (_fileName!.startsWith('http://') || _fileName!.startsWith('https://')) {
        debugPrint('FileUpload: 網路圖片預覽');
        imagePreview = Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Image.network(
            _fileName!,
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
          ),
        );
      } else if (_fileName!.startsWith('/') || _fileName!.startsWith('file://')) {
        debugPrint('FileUpload: 本地圖片預覽');
        imagePreview = Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Image.file(
            _fileName!.startsWith('file://') ? File(_fileName!.substring(7)) : File(_fileName!),
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
          ),
        );
      } else if (kIsWeb && _fileName!.startsWith('idb://')) {
        debugPrint('FileUpload: idb 圖片預覽');
        imagePreview = FutureBuilder<Uint8List?>(
          future: _loadIndexedDbImage(_fileName!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
            }
            if (snapshot.hasData && snapshot.data != null) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Image.memory(
                  snapshot.data!,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              );
            }
            return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
          },
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (imagePreview != null) imagePreview,
        MouseRegion(
          cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: (_) => isEnabled ? setState(() => _isHovered = true) : null,
          onExit: (_) => isEnabled ? setState(() => _isHovered = false) : null,
          child: GestureDetector(
            onTap: isEnabled && !_isLoading ? _pickFile : null,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              // 統一高度，避免內容不同導致高度變化
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                color: isEnabled ? widget.backgroundColor : Colors.grey[200],
                border: Border.all(
                  color: isEnabled
                      ? (_isHovered
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                          : Theme.of(context).dividerColor)
                      : Colors.grey[400]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: isEnabled && _isHovered
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: hasFile
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.attach_file, color: isEnabled && _isHovered ? Theme.of(context).colorScheme.primary : Colors.grey[700]),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.0),
                            child: Tooltip(
                              message: _fileName ?? '',
                              child: Text(
                                _fileName != null && _fileName!.length > 32
                                    ? _fileName!.substring(0, 29) + '...'
                                    : _fileName ?? '',
                                style: TextStyle(
                                  color: isEnabled && _isHovered ? Theme.of(context).colorScheme.primary : Colors.grey[800],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColor.danger, size: 22),
                            tooltip: '移除附件',
                            onPressed: isEnabled
                                ? () {
                                    setState(() {
                                      _fileName = null;
                                    });
                                    if (widget.onFileSelected != null) {
                                      widget.onFileSelected!(XFile(''));
                                    }
                                  }
                                : null,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.upload_file, color: isEnabled && _isHovered ? Theme.of(context).colorScheme.primary : Colors.grey[700]),
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            widget.label ?? '選擇檔案',
                            style: TextStyle(
                              color: isEnabled && _isHovered ? Theme.of(context).colorScheme.primary : Colors.grey[800],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.only(left: 12.0),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
