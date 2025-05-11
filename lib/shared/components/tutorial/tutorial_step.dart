
import 'package:flutter/material.dart';
import 'package:my_flutter_framework/shared/components/tutorial/gesture_type.dart';

class TutorialStep {
  final String? imageAssetPath;
  final String? targetWidgetId;
  final String? description;
  final String? title;
  final IconData? gestureIcon;
  final GestureType? gestureType; // 新增：手勢名稱

  static const Map<GestureType, IconData> gestureIconMap = {
    GestureType.tap: Icons.touch_app,
    GestureType.longPress: Icons.fingerprint,
    GestureType.doubleTap: Icons.double_arrow,
    GestureType.dragLeft: Icons.pan_tool_alt,
    GestureType.dragRight: Icons.pan_tool_alt,
    GestureType.dragUp: Icons.pan_tool_alt,
    GestureType.dragDown: Icons.pan_tool_alt,
    GestureType.swipe: Icons.swipe,
    GestureType.swipeLeft: Icons.swipe_left,
    GestureType.swipeRight: Icons.swipe_right,
    GestureType.swipeUp: Icons.swipe_up,
    GestureType.swipeDown: Icons.swipe_down,
    GestureType.zoom: Icons.zoom_in,
    GestureType.rotate: Icons.rotate_right,
  };

  String? get gestureName {
    if (gestureType != null) {
      return gestureType.toString().split('.').last;
    }
    return null;
  }

  TutorialStep({
    this.imageAssetPath,
    this.targetWidgetId,
    this.title,
    this.description,
    GestureType? gestureType,
  })  : gestureType = gestureType,
        gestureIcon = gestureType != null ? gestureIconMap[gestureType] : null;
}
