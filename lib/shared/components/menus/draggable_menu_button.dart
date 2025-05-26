import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:math' as Math;
import 'package:my_flutter_framework/shared/components/menus/circle_menu_bg_painter.dart';

// 定義 MenuItem 類別
class MenuItem {
  final String key;
  final String label;
  final void Function(String key)? onSelected;
  MenuItem({required this.key, required this.label, this.onSelected});
}

/// 可重用的拖曳選單按鈕元件
class DraggableMenuButton extends StatefulWidget {
  final List<MenuItem> menuItems;
  final double buttonSize;
  final double backgroundRadiusRatio;
  final double arcSweep;
  final double? arcStart;
  final Color? backgroundColor;

  const DraggableMenuButton({
    super.key,
    required this.menuItems,
    this.buttonSize = 80,
    this.backgroundRadiusRatio = 2.0,
    this.arcSweep = 2 * Math.pi,
    this.arcStart,
    this.backgroundColor,
  });

  // 常用 arcStart 方向常數
  static const double kArcStartUp = -Math.pi;
  static const double kArcStartUpRight = -Math.pi / 2;
  static const double kArcStartUpLeft = -Math.pi;
  static const double kArcStartDown = 0.0;
  static const double kArcStartDownRight = 0.0;
  static const double kArcStartDownLeft = Math.pi / 2;
  static const double kArcStartLeft = Math.pi / 2;
  static const double kArcStartRight = -Math.pi / 2;
  static const double kArcStartFullCircle = 2 * Math.pi;
  // 右側水平置中
  static const double kArcStartRightCenter = -Math.pi / 4;
  // 左側水平置中
  static const double kArcStartLeftCenter = 3 * Math.pi / 4;
  // 上側水平置中
  static const double kArcStartUpCenter = 3 * -Math.pi / 4;
  // 下側水平置中
  static const double kArcStartDownCenter = Math.pi / 4;


  @override
  State<DraggableMenuButton> createState() => _DraggableMenuButtonState();
}

class _DraggableMenuButtonState extends State<DraggableMenuButton> {
  final GlobalKey _buttonKey = GlobalKey();
  Offset _buttonOffset = const Offset(0, 0);
  Offset? _dragStartOffset;
  Offset? _buttonOrigin;
  Offset? _dragStartLocal;
  int? _activeMenuIndex;
  final Logger logger = Logger();
  OverlayEntry? _menuOverlayEntry;
  OverlayEntry? _buttonOverlayEntry;
  bool _isDragging = false;

  int _getMenuIndexByDirection(Offset? start, Offset? end, double radius) {
    try {
      if (start == null || end == null) return -1;
      if (start.dx.isNaN || start.dy.isNaN || end.dx.isNaN || end.dy.isNaN)
        return -1;
      final Offset delta = end - start;
      if (delta.distance < 20) return -1; // 拖曳太短不算
      double angle = Math.atan2(delta.dy, delta.dx);
      angle = angle < -Math.pi / 2 ? angle + 2 * Math.pi : angle;
      double sector = widget.arcSweep / widget.menuItems.length;
      int index =
          ((angle + Math.pi / 2 - (widget.arcStart ?? 0)) ~/ sector) %
          widget.menuItems.length;
      if (index < 0 || index >= widget.menuItems.length) return -1;
      return index;
    } catch (e) {
      return -1;
    }
  }

  void _showMenuOverlay(BuildContext context, double bgCircleSize, Offset globalOffset) {
    _menuOverlayEntry = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          left: globalOffset.dx + widget.buttonSize / 2 - bgCircleSize / 2,
          top: globalOffset.dy + widget.buttonSize / 2 - bgCircleSize / 2,
          child: IgnorePointer(
            child: CustomPaint(
              size: Size(bgCircleSize, bgCircleSize),
              painter: CircleMenuBgPainter(
                itemCount: widget.menuItems.length,
                color: widget.backgroundColor ?? Colors.blue.withOpacity(0.18),
                menuLabels: widget.menuItems.map((e) => e.label).toList(),
                arcSweep: widget.arcSweep,
                arcStart: widget.arcStart ?? DraggableMenuButton.kArcStartRight,
                backgroundRadiusRatio: widget.backgroundRadiusRatio,
                buttonCenter: Offset(bgCircleSize / 2, bgCircleSize / 2),
                buttonRadius: widget.buttonSize / 2,
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(_menuOverlayEntry!);
  }

  void _removeMenuOverlay() {
    _menuOverlayEntry?.remove();
    _menuOverlayEntry = null;
  }

  void _showButtonOverlay(BuildContext context, Offset globalOffset) {
    _buttonOverlayEntry = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          left: globalOffset.dx + _buttonOffset.dx,
          top: globalOffset.dy + _buttonOffset.dy,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(widget.buttonSize / 2),
            color: Colors.transparent,
            child: Container(
              width: widget.buttonSize,
              height: widget.buttonSize,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(widget.buttonSize / 2),
              ),
              alignment: Alignment.center,
              child: const Text(
                '拖曳我',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(_buttonOverlayEntry!);
  }

  void _removeButtonOverlay() {
    _buttonOverlayEntry?.remove();
    _buttonOverlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final double bgCircleSize =
        widget.buttonSize * widget.backgroundRadiusRatio * 1.4;
    return SizedBox(
      width: widget.buttonSize,
      height: widget.buttonSize,
      child: GestureDetector(
        onPanStart: (details) {
          _dragStartOffset = details.globalPosition;
          _dragStartLocal = details.localPosition;
          _buttonOrigin = _buttonOffset;
          _activeMenuIndex = null;
          _isDragging = true;
          final RenderBox? box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
          final Offset globalOffset = box?.localToGlobal(Offset.zero) ?? Offset.zero;
          _showMenuOverlay(context, bgCircleSize, globalOffset);
          _showButtonOverlay(context, globalOffset);
          setState(() {});
        },
        onPanUpdate: (details) {
          setState(() {
            _buttonOffset =
                _buttonOrigin! +
                (details.globalPosition - _dragStartOffset!);
            if (_dragStartLocal != null) {
              int idx = _getMenuIndexByDirection(
                _dragStartLocal,
                details.localPosition,
                widget.buttonSize / 2,
              );
              if (idx != _activeMenuIndex && idx >= 0) {
                _activeMenuIndex = idx;
              }
            }
          });
          _menuOverlayEntry?.markNeedsBuild();
          if (_buttonOverlayEntry != null) {
            _buttonOverlayEntry!.markNeedsBuild();
          }
        },
        onPanEnd: (details) {
          final int? menuIndex = _activeMenuIndex;
          setState(() {
            _buttonOffset = Offset(0, 0);
            _activeMenuIndex = null;
            _dragStartLocal = null;
            _isDragging = false;
          });
          _removeMenuOverlay();
          _removeButtonOverlay();
          if (menuIndex != null &&
              menuIndex >= 0 &&
              menuIndex < widget.menuItems.length) {
            widget.menuItems[menuIndex].onSelected?.call(widget.menuItems[menuIndex].key);
            if (widget.menuItems[menuIndex].onSelected == null && mounted) {
              logger.i('選擇了 ${widget.menuItems[menuIndex].label}');
            }
          }
        },
        child: Stack(
          children: [
            if (!_isDragging)
              Transform.translate(
                offset: _buttonOffset,
                child: Material(
                  key: _buttonKey,
                  elevation: 6,
                  borderRadius: BorderRadius.circular(widget.buttonSize / 2),
                  color: Colors.transparent,
                  child: Container(
                    width: widget.buttonSize,
                    height: widget.buttonSize,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(widget.buttonSize / 2),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '拖曳我',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
