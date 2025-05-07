import 'package:flutter/material.dart';
import 'package:my_flutter_framework/shared/utils/print_type.dart';


class MessageBox extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final PrintType type;
  final bool dismissOnBackgroundTap;
  final String confirmButtonText;
  final String cancelButtonText;

  const MessageBox({
    super.key,
    required this.title,
    required this.message,
    this.onConfirm,
    this.onCancel,
    this.type = PrintType.info,
    this.dismissOnBackgroundTap = true,
    this.confirmButtonText = 'Confirm',
    this.cancelButtonText = 'Cancel',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          PrintTypeUtil.getTypeIcon(type),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: PrintTypeUtil.getTypeColor(type)),
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
  PrintType type = PrintType.info,
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
