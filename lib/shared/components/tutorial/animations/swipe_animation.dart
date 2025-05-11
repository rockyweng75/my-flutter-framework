import 'package:flutter/material.dart';
import 'package:my_flutter_framework/shared/components/tutorial/gesture_type.dart';

class SwipeAnimation extends StatelessWidget {
  final GestureType type;
  final IconData icon;
  const SwipeAnimation({required this.type, required this.icon, super.key});
  @override
  Widget build(BuildContext context) {
    IconData arrow;
    switch (type) {
      case GestureType.swipeLeft:
        arrow = Icons.arrow_back;
        break;
      case GestureType.swipeRight:
        arrow = Icons.arrow_forward;
        break;
      case GestureType.swipeUp:
        arrow = Icons.arrow_upward;
        break;
      case GestureType.swipeDown:
        arrow = Icons.arrow_downward;
        break;
      default:
        arrow = Icons.swipe;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32, color: Colors.amberAccent),
        const SizedBox(width: 8),
        Icon(arrow, size: 28, color: Colors.amberAccent),
      ],
    );
  }
}
