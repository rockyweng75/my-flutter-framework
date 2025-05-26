import 'package:flutter/material.dart';
import 'dart:math' as Math;

import 'package:my_flutter_framework/shared/components/menus/draggable_menu_button.dart';


class CircleMenuBgPainter extends CustomPainter {
  final int itemCount;
  final Color color;
  final List<String> menuLabels;
  final double? arcSweep; // 弧度範圍
  final double arcStart; // 起始角度
  final double? backgroundRadiusRatio;
  final Offset? buttonCenter; // 按鈕中心座標
  final double? buttonRadius; // 按鈕半徑

  CircleMenuBgPainter({
    required this.itemCount,
    required this.color,
    required this.menuLabels,
    this.arcSweep,
    required this.arcStart,
    this.backgroundRadiusRatio,
    this.buttonCenter,
    this.buttonRadius, 
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final double sweep = (arcSweep ?? 2 * Math.pi) / itemCount;
    final double mainRadius = size.width / 2;
    final double radius = mainRadius * (backgroundRadiusRatio ?? 1.0);
    final double center = mainRadius;
    // 背景圓心改為按鈕中心座標（若有傳入）
    Offset circleCenter = Offset(center, center);
    // 根據背景弧度與起始角度自動調整圓心偏移
    if (buttonRadius != null) {
      final sweepValue = arcSweep ?? 2 * Math.pi;
      final startValue = arcStart;
      // 向上
      if (nearlyEqual(startValue, DraggableMenuButton.kArcStartUp)) {
        if(lessOrNearlyEqual(sweepValue, Math.pi / 2)){
          circleCenter = circleCenter.translate(buttonRadius! * 0.7, buttonRadius! * 0.7);
        } else {
          circleCenter = circleCenter.translate(0, buttonRadius! * 0.7);
        }
      }
      // 向右
      else if (nearlyEqual(startValue, DraggableMenuButton.kArcStartRight)) {
        if(lessOrNearlyEqual(sweepValue, Math.pi / 2)) {
          circleCenter = circleCenter.translate(-buttonRadius! * 0.7, buttonRadius! * 0.7);
        } else {
          circleCenter = circleCenter.translate(-buttonRadius! * 0.7, 0);
        }
      }
      // 向下
      else if (nearlyEqual(startValue, DraggableMenuButton.kArcStartDown)) {  
        if(lessOrNearlyEqual(sweepValue, Math.pi / 2)) {
          circleCenter = circleCenter.translate(buttonRadius! * 0.7, -buttonRadius! * 0.7);
        } else {
          circleCenter = circleCenter.translate(0, -buttonRadius! * 0.7);
        }
      }
      // 向左
      else if (nearlyEqual(startValue, DraggableMenuButton.kArcStartLeft)) {
        if(lessOrNearlyEqual(sweepValue, Math.pi / 2)) {
          circleCenter = circleCenter.translate(buttonRadius! * 0.7, -buttonRadius! * 0.7);
        } else {
          circleCenter = circleCenter.translate(buttonRadius! * 0.7, 0);
        }
      }
      else if (nearlyEqual(startValue, DraggableMenuButton.kArcStartRightCenter)) {
        // 小於半圓且方向向右（0度）
        if(lessOrNearlyEqual(sweepValue, Math.pi / 2)) {
          circleCenter = circleCenter.translate(-buttonRadius! * 0.7, 0);
        } else {
          circleCenter = circleCenter.translate(-buttonRadius! * 0.4, -buttonRadius! * 0.4);
        }
      }
      else if (nearlyEqual(startValue, DraggableMenuButton.kArcStartLeftCenter)) {
        // 小於半圓且方向向左（pi）
        if(lessOrNearlyEqual(sweepValue, Math.pi / 2)) {
          circleCenter = circleCenter.translate(buttonRadius! * 0.7, 0);
        } else {
          circleCenter = circleCenter.translate(buttonRadius! * 0.4, buttonRadius! * 0.4);
        }
      }
      else if (nearlyEqual(startValue, DraggableMenuButton.kArcStartUpCenter)) {
        // 小於半圓且方向向上（-pi/2）
        if(lessOrNearlyEqual(sweepValue, Math.pi / 2)) {
          circleCenter = circleCenter.translate(0, buttonRadius! * 0.7);
        } else {
          circleCenter = circleCenter.translate(-buttonRadius! * 0.4, buttonRadius! * 0.4);
        }
      }
      else if (nearlyEqual(startValue, DraggableMenuButton.kArcStartDownCenter)) {
        // 小於半圓且方向向下（pi）
        if (lessOrNearlyEqual(sweepValue, Math.pi / 2)) {
          circleCenter = circleCenter.translate(0, -buttonRadius! * 0.7);
        } else {
          circleCenter = circleCenter.translate(buttonRadius! * 0.4, -buttonRadius! * 0.4);
        }
      }
      // 其他情境可依需求擴充
    }

    // 自動根據按鈕位置決定偏移方向
    double startAngleBase = arcStart;

    final textStyle = TextStyle(
      color: Colors.blue[900],
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
    for (int i = 0; i < itemCount; i++) {
      // 修正：讓背景分割與 label 方向都以 arcStart 為基準
      final double startAngle = startAngleBase + sweep * i;
      paint.color = color.withOpacity(0.18 + 0.08 * (i % 2));
      canvas.drawArc(
        Rect.fromCircle(center: circleCenter, radius: radius),
        startAngle,
        sweep,
        true,
        paint,
      );
      // 畫文字
      final double labelAngle = startAngle + sweep / 2;
      final Offset labelPos = Offset(
        circleCenter.dx + (radius * 0.65) * Math.cos(labelAngle),
        circleCenter.dy + (radius * 0.65) * Math.sin(labelAngle),
      );
      final textSpan = TextSpan(text: menuLabels[i], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      canvas.save();
      canvas.translate(labelPos.dx, labelPos.dy);
      // 讓 label 文字正立，與圓弧方向一致
      // 若 arcStart 方向為向下，則額外旋轉 180 度
      double rotateAngle = labelAngle + Math.pi / 2;
      // arcStart 預設值已在外部處理，這裡直接比較即可
      if (nearlyEqual(arcStart, DraggableMenuButton.kArcStartDown) ||
          nearlyEqual(arcStart, DraggableMenuButton.kArcStartDownLeft) ||
          nearlyEqual(arcStart, DraggableMenuButton.kArcStartDownRight) || 
          nearlyEqual(arcStart, DraggableMenuButton.kArcStartDownCenter)) {
        rotateAngle += Math.pi;
      }
      canvas.rotate(rotateAngle);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  // 浮點數誤差容忍比較
  bool nearlyEqual(double a, double b, [double epsilon = 1e-5]) {
    return (a - b).abs() < epsilon;
  }

  // 大於等於（含誤差）
  bool greaterOrNearlyEqual(double a, double b, [double epsilon = 1e-5]) {
    return a > b - epsilon;
  }

  // 小於等於（含誤差）
  bool lessOrNearlyEqual(double a, double b, [double epsilon = 1e-5]) {
    return a < b + epsilon;
  }

  // 嚴格大於（排除近似相等）
  bool strictlyGreater(double a, double b, [double epsilon = 1e-5]) {
    return a > b + epsilon;
  }

  // 嚴格小於（排除近似相等）
  bool strictlyLess(double a, double b, [double epsilon = 1e-5]) {
    return a < b - epsilon;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
