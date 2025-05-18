import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:my_flutter_framework/styles/app_color.dart';

class FullWidthCardAction extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool confirmOnLeft;
  final Icon? confirmIcon;
  final Icon? cancelIcon;
  final Color? cardColor;
  final Color? textColor;
  final double height;
  final Widget child;

  const FullWidthCardAction({
    super.key,
    required this.onConfirm,
    this.onCancel,
    this.confirmOnLeft = false,
    this.confirmIcon,
    this.cancelIcon,
    this.cardColor,
    this.textColor,
    this.height = 80,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = this.cardColor ?? Theme.of(context).colorScheme.surface;
    final isWeb = kIsWeb;

    Widget swipeCard = Dismissible(
      key: key ?? UniqueKey(),
      direction:
          onCancel != null
              ? DismissDirection.horizontal
              : (confirmOnLeft
                  ? DismissDirection.startToEnd
                  : DismissDirection.endToStart),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart && !confirmOnLeft) {
          onConfirm();
        } else if (direction == DismissDirection.startToEnd && confirmOnLeft) {
          onConfirm();
        } else if (onCancel != null) {
          onCancel!();
        }
        // Dismissible 會自動移除 widget，不需 setState
      },
      background: Container(
        decoration: BoxDecoration(
          color: AppColor.success.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (!confirmOnLeft) const SizedBox(width: 12),
            confirmIcon ?? const Icon(Icons.check_circle, color: AppColor.success, size: 40),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
      secondaryBackground:
          onCancel != null
              ? Container(
                  decoration: BoxDecoration(
                    color: AppColor.danger.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      cancelIcon ?? const Icon(Icons.delete, color: AppColor.danger, size: 40),
                      const SizedBox(width: 12),
                    ],
                  ),
                )
              : null,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: child,
        ),
      ),
    );

    if (isWeb) {
      return MouseRegion(cursor: SystemMouseCursors.grab, child: swipeCard);
    } else {
      return swipeCard;
    }
  }
}
