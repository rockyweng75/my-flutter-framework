import 'package:flutter/material.dart';
import 'package:my_flutter_framework/shared/utils/print_type.dart';

class ReusableNotification {
  static ReusableNotification? _instance;
  final BuildContext context;
  final List<OverlayEntry> _overlayEntries = [];

  ReusableNotification._internal(this.context);

  factory ReusableNotification(BuildContext context) {
    return _instance ??= ReusableNotification._internal(context);
  }

  void show(String message, {PrintType type = PrintType.info, Duration duration = const Duration(seconds: 2)}) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    double topOffset = 50.0;

    for (final entry in _overlayEntries) {
      topOffset += 60.0; // 每個訊息往下移動 60 像素
    }

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: topOffset,
        left: 10.0,
        right: 10.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: PrintTypeUtil.getTypeColor(type),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                PrintTypeUtil.getTypeIcon(
                  type: type,
                  isLight: true,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
              ],
            ),
          ),
        ),
      ),
    );

    _overlayEntries.add(overlayEntry);
    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
      _overlayEntries.remove(overlayEntry);
    });
  }
}