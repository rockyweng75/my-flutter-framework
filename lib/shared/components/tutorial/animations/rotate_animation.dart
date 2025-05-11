import 'package:flutter/material.dart';

class RotateAnimation extends StatelessWidget {
  final IconData icon;
  const RotateAnimation({required this.icon, super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32, color: Colors.amberAccent),
        const SizedBox(width: 8),
        Icon(Icons.rotate_right, size: 28, color: Colors.amberAccent),
      ],
    );
  }
}
