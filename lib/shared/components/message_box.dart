import 'package:flutter/material.dart';
import 'package:my_flutter_framework/styles/app_color.dart';

enum MessageBoxType { primary, success, info, warning, danger }

class MessageBox extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final MessageBoxType type;
  final bool dismissOnBackgroundTap;
  final String confirmButtonText;
  final String cancelButtonText;

  const MessageBox({
    super.key,
    required this.title,
    required this.message,
    this.onConfirm,
    this.onCancel,
    this.type = MessageBoxType.info,
    this.dismissOnBackgroundTap = true,
    this.confirmButtonText = 'Confirm',
    this.cancelButtonText = 'Cancel',
  });

  Icon _getTypeIcon() {
    switch (type) {
      case MessageBoxType.primary:
        return const Icon(Icons.info, color: AppColor.info);
      case MessageBoxType.success:
        return const Icon(Icons.check_circle, color: AppColor.success);
      case MessageBoxType.info:
        return const Icon(Icons.info_outline, color: AppColor.primary);
      case MessageBoxType.warning:
        return const Icon(Icons.warning, color: AppColor.warning);
      case MessageBoxType.danger:
        return const Icon(Icons.error, color: AppColor.danger);
    }
  }

  Color _getTypeColor() {
    switch (type) {
      case MessageBoxType.primary:
        return AppColor.info;
      case MessageBoxType.success:
        return AppColor.success;
      case MessageBoxType.info:
        return AppColor.primary;
      case MessageBoxType.warning:
        return AppColor.warning;
      case MessageBoxType.danger:
        return AppColor.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          _getTypeIcon(),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: _getTypeColor()),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Text(
          message,
          overflow: TextOverflow.visible,
        ),
      ),
      actions: [
        if (onCancel != null)
          TextButton(
            onPressed: onCancel,
            child: Text(cancelButtonText),
          ),
        if (onConfirm != null)
          TextButton(
            onPressed: onConfirm,
            child: Text(confirmButtonText),
          ),
      ],
    );
  }
}

void showMessageBox({
  required BuildContext context,
  required String title,
  required String message,
  MessageBoxType type = MessageBoxType.info,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  bool dismissOnBackgroundTap = true,
}) {
  showDialog(
    context: context,
    barrierDismissible: dismissOnBackgroundTap,
    builder: (context) => MessageBox(
      title: title,
      message: message,
      type: type,
      onConfirm: onConfirm,
      onCancel: onCancel,
      dismissOnBackgroundTap: dismissOnBackgroundTap,
    ),
  );
}
