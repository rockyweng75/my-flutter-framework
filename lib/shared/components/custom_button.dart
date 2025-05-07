import 'package:flutter/material.dart';
import 'package:my_flutter_framework/shared/models/custom_style.dart';

class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Widget? icon;
  final ButtonType type;
  final CustomStyle style; // 使用 CustomStyle 進行樣式設定

  CustomButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.type = ButtonType.text,
    CustomStyle? style, // 接收可為 null 的 CustomStyle
    super.key,
  })  : style = style ?? CustomStyle();

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isHovered = false;
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (mounted) {
          setState(() {
            _isHovered = true;
          });
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() {
            _isHovered = false;
          });
        }
      },
      child: GestureDetector(
        onTap: () {
          widget.onTap();
        },
        onTapDown: (_) {
          if (mounted) {
            setState(() {
              _isTapped = true;
            });
          }
        },
        onTapUp: (_) {
          if (mounted) {
            setState(() {
              _isTapped = false;
            });
          }
        },
        onTapCancel: () {
          if (mounted) {
            setState(() {
              _isTapped = false;
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isTapped
                ? widget.style.backgroundColor?.withOpacity(0.6)
                : _isHovered
                    ? widget.style.backgroundColor?.withOpacity(0.8)
                    : widget.style.backgroundColor,
            border: widget.style.border ?? Border.all(color: Colors.transparent),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          height: _isHovered ? 60 : 50,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null)
          IconTheme(
            data: IconThemeData(color: widget.style.textStyle?.color),
            child: widget.icon!,
          ),
        if (widget.icon != null) const SizedBox(width: 8),
        Text(
          widget.label,
          style: widget.style.textStyle ?? const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

enum ButtonType { text, icon, mixed }
