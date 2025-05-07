import 'package:flutter/material.dart';

class CustomStyle {
  TextStyle? textStyle;
  Color? backgroundColor;
  Border? border;

  CustomStyle({
    this.textStyle,
    this.backgroundColor,
    this.border,
  });

  CustomStyle copyWith({
    TextStyle? textStyle,
    Color? backgroundColor,
    Border? border,
  }) {
    return CustomStyle(
      textStyle: textStyle ?? this.textStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
    );
  }
}