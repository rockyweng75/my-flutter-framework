import 'package:flutter/material.dart';
import 'package:my_flutter_framework/styles/theme_data.dart';

class LongPressAnimation extends StatefulWidget {
  final IconData icon;
  const LongPressAnimation({required this.icon, super.key});
  @override
  State<LongPressAnimation> createState() => _LongPressAnimationState();
}

class _LongPressAnimationState extends State<LongPressAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Icon(
        widget.icon,
        size: 36,
        color: Colors.amberAccent,
      ),
    );
  }
}
