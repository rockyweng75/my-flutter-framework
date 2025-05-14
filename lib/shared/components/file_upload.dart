import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

class FileUpload extends StatefulWidget {
  final void Function(XFile file)? onFileSelected;
  final String? label;
  final String? accept;
  final bool allowMultiple;
  final Color? backgroundColor;

  const FileUpload({
    super.key,
    this.onFileSelected,
    this.label,
    this.accept,
    this.allowMultiple = false,
    this.backgroundColor,
  });

  @override
  State<FileUpload> createState() => _FileUploadState();
}

class _FileUploadState extends State<FileUpload> {
  String? _fileName;
  bool _isLoading = false;
  bool _isHovered = false;

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

  @override
  Widget build(BuildContext context) {
    final hasFile = _fileName != null && _fileName!.isNotEmpty;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _isLoading ? null : _pickFile,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          // 統一高度，避免內容不同導致高度變化
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            border: Border.all(
              color: _isHovered
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                  : Theme.of(context).dividerColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered
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
                      child: Icon(Icons.attach_file, color: _isHovered ? Theme.of(context).colorScheme.primary : Colors.grey[700]),
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
                              color: _isHovered ? Theme.of(context).colorScheme.primary : Colors.grey[800],
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
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                        tooltip: '移除附件',
                        onPressed: () {
                          setState(() {
                            _fileName = null;
                          });
                          if (widget.onFileSelected != null) {
                            widget.onFileSelected!(XFile(''));
                          }
                        },
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
                      child: Icon(Icons.upload_file, color: _isHovered ? Theme.of(context).colorScheme.primary : Colors.grey[700]),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        widget.label ?? '選擇檔案',
                        style: TextStyle(
                          color: _isHovered ? Theme.of(context).colorScheme.primary : Colors.grey[800],
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
    );
  }
}
