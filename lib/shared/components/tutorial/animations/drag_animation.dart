import 'package:flutter/material.dart';
import 'package:my_flutter_framework/shared/components/tutorial/gesture_type.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_step.dart';

class DragAnimation extends StatefulWidget {
  final GestureType type;
  final IconData icon;
  const DragAnimation({required this.type, required this.icon, super.key});
  @override
  State<DragAnimation> createState() => _DragAnimationState();
}

class _DragAnimationState extends State<DragAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    Offset begin = Offset.zero;
    Offset end;
    switch (widget.type) {
      case GestureType.dragLeft:
        end = const Offset(-0.5, 0);
        break;
      case GestureType.dragRight:
        end = const Offset(0.5, 0);
        break;
      case GestureType.dragUp:
        end = const Offset(0, -0.5);
        break;
      case GestureType.dragDown:
        end = const Offset(0, 0.5);
        break;
      default:
        end = Offset.zero;
    }
    _offsetAnim = Tween<Offset>(begin: begin, end: end).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnim,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            () {
              switch (widget.type) {
                case GestureType.dragLeft:
                  return TutorialStep.gestureIconMap[GestureType.dragLeft] ?? Icons.arrow_back;
                case GestureType.dragRight:
                  return TutorialStep.gestureIconMap[GestureType.dragRight] ?? Icons.arrow_forward;
                case GestureType.dragUp:
                  return TutorialStep.gestureIconMap[GestureType.dragUp] ?? Icons.arrow_upward;
                case GestureType.dragDown:
                  return TutorialStep.gestureIconMap[GestureType.dragDown] ?? Icons.arrow_downward;
                default:
                  return Icons.open_with;
              }
            }(),
            size: 36,
            color: Colors.amberAccent,
          ),
        ],
      ),
    );
  }
}
