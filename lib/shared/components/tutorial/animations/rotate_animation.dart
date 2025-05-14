import 'package:flutter/material.dart';
import 'package:my_flutter_framework/styles/theme_data.dart';

class RotateAnimation extends StatelessWidget {
  final IconData icon;
  const RotateAnimation({required this.icon, super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32, color: Colors.amberAccent),
      ],
    );
  }
}
