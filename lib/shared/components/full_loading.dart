import 'package:flutter/material.dart';
import 'package:my_flutter_framework/styles/app_color.dart';

class FullLoading extends StatelessWidget {
  static OverlayEntry? _overlayEntry;

  const FullLoading._internal();

  static void show(BuildContext context) {
    if (_overlayEntry != null) return; // 防止重複顯示

    _overlayEntry = OverlayEntry(
      builder: (context) => const FullLoading._internal(),
    );

    Overlay.of(context)?.insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(
          dismissible: false,
          color: AppColor.blockBackground,
        ),
        const Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}