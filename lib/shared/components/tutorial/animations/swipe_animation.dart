import 'package:flutter/material.dart';
import 'package:my_flutter_framework/shared/components/tutorial/gesture_type.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_step.dart';
import 'package:my_flutter_framework/styles/theme_data.dart';

class SwipeAnimation extends StatefulWidget {
  final GestureType type;
  final IconData icon;
  const SwipeAnimation({required this.type, required this.icon, super.key});
  @override
  State<SwipeAnimation> createState() => _SwipeAnimationState();
}

class _SwipeAnimationState extends State<SwipeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _setAnimByType(widget.type);
    _controller.repeat(reverse: true);
  }

  void _setAnimByType(GestureType type) {
    Offset begin, end;
    switch (type) {
      case GestureType.swipeLeft:
        begin = Offset.zero;
        end = const Offset(-0.5, 0);
        break;
      case GestureType.swipeRight:
        begin = Offset.zero;
        end = const Offset(0.5, 0);
        break;
      case GestureType.swipeUp:
        begin = Offset.zero;
        end = const Offset(0, -0.5);
        break;
      case GestureType.swipeDown:
        begin = Offset.zero;
        end = const Offset(0, 0.5);
        break;
      default:
        begin = Offset.zero;
        end = Offset.zero;
    }
    _offsetAnim = Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant SwipeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      _setAnimByType(widget.type);
      _controller.reset();
      _controller.repeat(reverse: true);
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
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
                case GestureType.swipeLeft:
                  return TutorialStep.gestureIconMap[GestureType.swipeLeft] ??
                      Icons.arrow_back;
                case GestureType.swipeRight:
                  return TutorialStep.gestureIconMap[GestureType.swipeRight] ??
                      Icons.arrow_forward;
                case GestureType.swipeUp:
                  return TutorialStep.gestureIconMap[GestureType.swipeUp] ??
                      Icons.arrow_upward;
                case GestureType.swipeDown:
                  return TutorialStep.gestureIconMap[GestureType.swipeDown] ??
                      Icons.arrow_downward;
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
