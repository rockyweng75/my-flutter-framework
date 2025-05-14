import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:my_flutter_framework/shared/components/message_box.dart';
import 'package:my_flutter_framework/shared/utils/print_type.dart';
import 'package:my_flutter_framework/shared/utils/image_compress_util.dart';

class ImageUpload extends StatefulWidget {
  final void Function(XFile file)? onImageSelected;
  final String? label;
  final String? accept;
  final bool allowMultiple;
  final Color? backgroundColor;
  final bool isDebug;

  const ImageUpload({
    super.key,
    this.onImageSelected,
    this.label,
    this.accept = 'jpg,jpeg,png,gif',
    this.allowMultiple = false,
    this.backgroundColor,
    this.isDebug = false,
  });

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  String? _fileName;
  XFile? _imageFile;
  bool _isLoading = false;
  bool _isHovered = false;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (e) {
      // ignore error, fallback to image_picker
      if (kIsWeb && mounted) {
        showMessageBox(
          context: context,
          title: '無法存取相機',
          message: '請檢查瀏覽器權限設定，允許本網站存取相機。',
          type: PrintType.warning,
          dismissOnBackgroundTap: true,
        );
      } else {
        if (!mounted) return;
        showMessageBox(
          context: context,
          title: '無法存取相機',
          message: '請檢查裝置的相機權限設定。',
          type: PrintType.warning,
          dismissOnBackgroundTap: true,
        );
      }
    }
  }

  Future<void> _pickImage() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final typeGroups =
          (widget.accept != null && widget.accept!.isNotEmpty)
              ? [
                XTypeGroup(
                  extensions:
                      widget.accept!.split(',').map((e) => e.trim()).toList(),
                ),
              ]
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
          _imageFile = files.first;
        });
        if (widget.onImageSelected != null) {
          widget.onImageSelected!(files.first);
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFromCamera() async {
    setState(() {
      _isCameraReady = false;
    });
    await _cameraController?.dispose();
    _cameraController = null;
    await _initCameras();
    if (_isCameraReady && _cameraController != null) {
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child:
                        (_cameraController != null &&
                                _cameraController!.value.isInitialized)
                            ? AspectRatio(
                              aspectRatio: _cameraController!.value.aspectRatio,
                              child: CameraPreview(_cameraController!),
                            )
                            : const Center(child: CircularProgressIndicator()),
                  ),
                  Positioned(
                    bottom: 32,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('拍照'),
                          onPressed: () async {
                            final file = await _cameraController!.takePicture();
                            if (!mounted) return;
                            // 拍照後預覽圖片
                            await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (dialogContext) {
                                return Scaffold(
                                  backgroundColor: Colors.black,
                                  body: SafeArea(
                                    child: Stack(
                                      children: [
                                        Center(
                                          child:
                                              kIsWeb
                                                  ? FutureBuilder<Uint8List>(
                                                    future: file.readAsBytes(),
                                                    builder: (
                                                      context,
                                                      snapshot,
                                                    ) {
                                                      if (snapshot.connectionState ==
                                                              ConnectionState
                                                                  .done &&
                                                          snapshot.hasData) {
                                                        return Image.memory(
                                                          snapshot.data!,
                                                          fit: BoxFit.contain,
                                                        );
                                                      } else {
                                                        return const CircularProgressIndicator();
                                                      }
                                                    },
                                                  )
                                                  : Image.file(
                                                    File(file.path),
                                                    fit: BoxFit.contain,
                                                  ),
                                        ),
                                        Positioned(
                                          bottom: 32,
                                          left: 0,
                                          right: 0,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  foregroundColor: Colors.black,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          24,
                                                        ),
                                                  ),
                                                ),
                                                icon: const Icon(Icons.check),
                                                label: const Text('使用此照片'),
                                                onPressed: () async {
                                                  XFile resultFile = XFile(
                                                    file.path,
                                                  );
                                                  if (kIsWeb) {
                                                    final bytes =
                                                        await file
                                                            .readAsBytes();
                                                    // 產生唯一檔名（時間戳記）
                                                    final now = DateTime.now();
                                                    final ext =
                                                        file.mimeType
                                                            ?.split('/')
                                                            .last ??
                                                        'jpg';
                                                    final name =
                                                        'web_image_${now.millisecondsSinceEpoch}.$ext';
                                                    resultFile = XFile.fromData(
                                                      bytes,
                                                      name: name,
                                                      mimeType:
                                                          file.mimeType ??
                                                          'image/jpeg',
                                                    );
                                                  }
                                                  resultFile =
                                                      await ImageCompressUtil.compressImageToTargetSize(
                                                        resultFile,
                                                        maxSizeBytes:
                                                            500 * 1024,
                                                      );
                                                  if (!mounted ||
                                                      !(dialogContext.mounted))
                                                    return;
                                                  setState(() {
                                                    _fileName = resultFile.name;
                                                    _imageFile = resultFile;
                                                  });
                                                  if (widget.onImageSelected !=
                                                      null) {
                                                    widget.onImageSelected!(
                                                      resultFile,
                                                    );
                                                  }
                                                  if (Navigator.of(
                                                    dialogContext,
                                                  ).canPop()) {
                                                    Navigator.of(
                                                      dialogContext,
                                                    ).pop(); // 關閉預覽
                                                  }
                                                  if (Navigator.of(
                                                    context,
                                                  ).canPop()) {
                                                    Navigator.of(
                                                      context,
                                                    ).pop(); // 關閉相機
                                                  }
                                                },
                                              ),
                                              const SizedBox(width: 24),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  foregroundColor: Colors.black,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          24,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  if (dialogContext.mounted &&
                                                      Navigator.of(
                                                        dialogContext,
                                                      ).canPop()) {
                                                    Navigator.of(
                                                      dialogContext,
                                                    ).pop(); // 只 pop 預覽，不 pop 相機
                                                  }
                                                },
                                                child: const Text('重拍'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('取消'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _showSourcePicker() {
    // 不要用 _isLoading 阻擋 showModalBottomSheet
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      Navigator.pop(context);
                      await _pickFromCamera();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        const Text('相機'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      Navigator.pop(context);
                      await _pickImage();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder,
                          size: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        const Text('硬碟/相簿'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 僅供測試用：設定檔名與檔案
  void setFileForTest(String? name, XFile? file) {
    setState(() {
      _fileName = name;
      _imageFile = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = _fileName != null && _fileName!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // DEBUG 區塊
        if (widget.isDebug)
          FutureBuilder<int>(
            future: _imageFile?.length(),
            builder: (context, snapshot) {
              final sizeStr =
                  (snapshot.hasData && _imageFile != null)
                      ? '${(snapshot.data! / 1024).toStringAsFixed(1)} KB'
                      : '-';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: Container(
                    color: Colors.grey[200],
                    padding: const EdgeInsets.all(8),
                    child: SingleChildScrollView(
                      child: Text(
                        '[DEBUG]\n_fileName: \\${_fileName ?? ''}\n_imageFile: \\${_imageFile?.path ?? ''}\n檔案大小: $sizeStr\n_isLoading: \\$_isLoading\n_isHovered: \\$_isHovered\n_isCameraReady: \\$_isCameraReady',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: _buildButton(context, hasFile: hasFile),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, {required bool hasFile}) {
    if (!hasFile) {
      return GestureDetector(
        onTap: _showSourcePicker,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            border: Border.all(
              color:
                  _isHovered
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                      : Theme.of(context).dividerColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow:
                _isHovered
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.image,
                  color:
                      _isHovered
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[700],
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  widget.label ?? '選擇圖片',
                  style: TextStyle(
                    color:
                        _isHovered
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[800],
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
      );
    }
    // 已選擇檔案時的顯示
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: Border.all(
          color:
              _isHovered
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                  : Theme.of(context).dividerColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow:
            _isHovered
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (_imageFile != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.network(
                _imageFile!.path,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.image, size: 32, color: Colors.grey),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.image,
                color:
                    _isHovered
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[700],
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Tooltip(
                message: _fileName ?? '',
                child: Text(
                  _fileName != null && _fileName!.length > 32
                      ? _fileName!.substring(0, 29) + '...'
                      : _fileName ?? '',
                  style: TextStyle(
                    color:
                        _isHovered
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[800],
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
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 22,
              ),
              tooltip: '移除圖片',
              onPressed: () {
                setState(() {
                  _fileName = null;
                  _imageFile = null;
                });
                if (widget.onImageSelected != null) {
                  widget.onImageSelected!(XFile(''));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
