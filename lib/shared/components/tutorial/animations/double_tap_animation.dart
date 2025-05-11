import 'package:flutter/material.dart';

class DoubleTapAnimation extends StatefulWidget {
  final IconData icon;
  const DoubleTapAnimation({required this.icon, super.key});
  @override
  State<DoubleTapAnimation> createState() => _DoubleTapAnimationState();
}
class _DoubleTapAnimationState extends State<DoubleTapAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _opacityAnim = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: _opacityAnim,
          child: Icon(widget.icon, size: 32, color: Colors.amberAccent.withOpacity(0.5)),
        ),
      ],
    );
  }
}
