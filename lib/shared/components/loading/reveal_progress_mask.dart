import 'package:flutter/material.dart';

class RevealProgressMask extends StatefulWidget {
  final double? progress; // 0.0 ~ 1.0，可選
  final Color maskColor;
  final Widget child;

  const RevealProgressMask({
    super.key,
    this.progress,
    required this.child,
    this.maskColor = const Color(0xCC000000),
  });

  @override
  State<RevealProgressMask> createState() => _RevealProgressMaskState();
}

class _RevealProgressMaskState extends State<RevealProgressMask>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.progress == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      )..repeat();
    }
  }

  @override
  void dispose() {
    if (widget.progress == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress;
    if (progress != null) {
      // 外部傳入進度
      return Stack(
        children: [
          widget.child,
          if (progress < 1.0)
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                builder: (context, value, _) {
                  return CustomPaint(
                    painter: _RevealMaskPainter(
                      progress: value,
                      maskColor: widget.maskColor,
                    ),
                  );
                },
              ),
            ),
        ],
      );
    } else {
      // 自動循環進度
      return Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _RevealMaskPainter(
                    progress: _controller.value,
                    maskColor: widget.maskColor,
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
  }
}

class _RevealMaskPainter extends CustomPainter {
  final double progress; // 0.0 ~ 1.0
  final Color maskColor;
  _RevealMaskPainter({required this.progress, required this.maskColor});

  @override
  void paint(Canvas canvas, Size size) {
    double revealWidth = size.width * progress;
    final paint = Paint()..color = maskColor;
    canvas.drawRect(
      Rect.fromLTWH(revealWidth, 0, size.width - revealWidth, size.height),
      paint,
    );

    if (progress < 1.0) {
      final double arrowCenterX = revealWidth + 20;
      final double arrowCenterY = size.height / 2 - 20;
      final double arrowWidth = 36;
      final double arrowHeight = 36;

      final Path arrowPath = Path();
      arrowPath.moveTo(
        arrowCenterX - arrowWidth / 2,
        arrowCenterY - arrowHeight / 4,
      );
      arrowPath.lineTo(
        arrowCenterX + arrowWidth / 4,
        arrowCenterY - arrowHeight / 4,
      );
      arrowPath.lineTo(
        arrowCenterX + arrowWidth / 4,
        arrowCenterY - arrowHeight / 2,
      );
      arrowPath.lineTo(arrowCenterX + arrowWidth / 2, arrowCenterY);
      arrowPath.lineTo(
        arrowCenterX + arrowWidth / 4,
        arrowCenterY + arrowHeight / 2,
      );
      arrowPath.lineTo(
        arrowCenterX + arrowWidth / 4,
        arrowCenterY + arrowHeight / 4,
      );
      arrowPath.lineTo(
        arrowCenterX - arrowWidth / 2,
        arrowCenterY + arrowHeight / 4,
      );
      arrowPath.close();

      final Paint arrowPaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill
            ..isAntiAlias = true;
      canvas.drawPath(arrowPath, arrowPaint);

      final double progressInfoCenterX = revealWidth + 20;
      final double progressInfoCenterY = size.height / 2 + 20;
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: '${(progress * 100).toInt()}%',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          progressInfoCenterX - textPainter.width / 2,
          progressInfoCenterY - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RevealMaskPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.maskColor != maskColor;
  }
}
