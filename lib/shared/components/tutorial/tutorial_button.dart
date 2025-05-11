import 'package:flutter/material.dart';
import 'package:my_flutter_framework/shared/components/tutorial/animations/double_tap_animation.dart';
import 'package:my_flutter_framework/shared/components/tutorial/animations/drag_animation.dart';
import 'package:my_flutter_framework/shared/components/tutorial/animations/long_press_animation.dart';
import 'package:my_flutter_framework/shared/components/tutorial/animations/rotate_animation.dart';
import 'package:my_flutter_framework/shared/components/tutorial/animations/swipe_animation.dart';
import 'package:my_flutter_framework/shared/components/tutorial/animations/tap_animation.dart';
import 'package:my_flutter_framework/shared/components/tutorial/animations/zoom_animation.dart';
import 'package:my_flutter_framework/shared/components/tutorial/gesture_type.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_step.dart';
import 'package:my_flutter_framework/styles/app_color.dart';

// 假設你有一個全域 Map<String, GlobalKey> 來註冊元件
final Map<String, GlobalKey> globalWidgetRegistry = {};

/// 教學頁元件：一個 IconButton，點擊後彈出 Dialog 顯示教學內容。
/// 支援顯示整頁圖片，或根據元件 id 遮罩特定元件。
class TutorialButton extends StatelessWidget {
  final List<TutorialStep> steps;
  final IconData icon;
  final String prevLabel;
  final String nextLabel;
  final String doneLabel;
  final String? tooltipMessage;

  const TutorialButton({
    super.key,
    required this.steps,
    this.icon = Icons.help_outline,
    this.prevLabel = '上一步',
    this.nextLabel = '下一步',
    this.doneLabel = '完成',
    this.tooltipMessage = '教學',
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipMessage,
      child: IconButton(
        icon: Icon(icon),
        onPressed: () => _showTutorial(context),
      ),
    );
  }

  void _showTutorial(BuildContext context) {
    if (steps.isEmpty) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => _TutorialScreen(
            steps: steps,
            prevLabel: prevLabel,
            nextLabel: nextLabel,
            doneLabel: doneLabel,
          ),
    );
  }
}

class _TutorialScreen extends StatefulWidget {
  final List<TutorialStep> steps;
  final String prevLabel;
  final String nextLabel;
  final String doneLabel;

  const _TutorialScreen({
    required this.steps,
    required this.prevLabel,
    required this.nextLabel,
    required this.doneLabel,
  });

  @override
  State<_TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<_TutorialScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    setState(() {
      _current = index;
    });
    // 若要動畫可保留 animateToPage，但 UI 切換要靠 setState
    _controller.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_current];
    // 支援模糊查詢 targetWidgetId
    GlobalKey? targetKey;
    if (step.targetWidgetId != null) {
      targetKey =
          globalWidgetRegistry.entries
              .firstWhere(
                (entry) => entry.key.contains(step.targetWidgetId!),
                orElse:
                    () => MapEntry<String, GlobalKey>(
                      '__not_found__',
                      GlobalKey(),
                    ),
              )
              .value;
    }
    Rect? targetRect;

    if (targetKey != null && targetKey.currentContext != null) {
      final renderBox =
          targetKey.currentContext!.findRenderObject() as RenderBox;
      final offset = renderBox.localToGlobal(Offset.zero);
      targetRect = offset & renderBox.size;
    }

    return Stack(
      children: [
        // 遮罩層
        GestureDetector(
          onTap: () {}, // 防止點擊穿透
          child: CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _SpotlightPainter(targetRect),
          ),
        ),
        // 教學內容
        Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 32.0,
                      left: 32.0,
                      right: 32.0,
                      bottom: 0,
                    ),
                    child: _buildStepContent(step),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: widget.steps.length,
                      onPageChanged: (i) => setState(() => _current = i),
                      itemBuilder: (context, index) {
                        // 內容已移到上方，這裡只回傳空容器
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  // 新增：手勢動作區塊移到下方，支援動畫
                  if (step.gestureIcon != null || step.gestureType != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        children: [
                          if (step.gestureType != null)
                            _buildGestureAnimation(step.gestureType!),
                          if (step.gestureType != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                step.gestureName!,
                                style: const TextStyle(fontSize: 16, color: Colors.amberAccent, fontStyle: FontStyle.italic),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  _buildDots(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_current > 0)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                            ),
                            onPressed: () => _goTo(_current - 1),
                            child: Text(
                              widget.prevLabel,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        const SizedBox(width: 16),
                        if (_current < widget.steps.length - 1)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                            ),
                            onPressed: () => _goTo(_current + 1),
                            child: Text(
                              widget.nextLabel,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        if (_current == widget.steps.length - 1)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              widget.doneLabel,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(TutorialStep step) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (step.imageAssetPath != null && step.imageAssetPath!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Image.asset(step.imageAssetPath!, height: 180),
          ),
        if (step.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              step.title!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (step.description != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              step.description!,
              style: const TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildGestureAnimation(GestureType type) {
    switch (type) {
      case GestureType.tap:
        return TapAnimation(icon: TutorialStep.gestureIconMap[type]!);
      case GestureType.longPress:
        return LongPressAnimation(icon: TutorialStep.gestureIconMap[type]!);
      case GestureType.doubleTap:
        return DoubleTapAnimation(icon: TutorialStep.gestureIconMap[type]!);
      case GestureType.dragLeft:
      case GestureType.dragRight:
      case GestureType.dragUp:
      case GestureType.dragDown:
        return DragAnimation(type: type, icon: TutorialStep.gestureIconMap[type]!);
      case GestureType.swipe:
      case GestureType.swipeLeft:
      case GestureType.swipeRight:
      case GestureType.swipeUp:
      case GestureType.swipeDown:
        return SwipeAnimation(type: type, icon: TutorialStep.gestureIconMap[type]!);
      case GestureType.zoom:
        return ZoomAnimation(icon: TutorialStep.gestureIconMap[type]!);
      case GestureType.rotate:
        return RotateAnimation(icon: TutorialStep.gestureIconMap[type]!);
    }
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.steps.length, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          width: _current == i ? 16 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _current == i ? AppColor.primary : Colors.white54,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// 遮罩畫家：挖洞 spotlight
class _SpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  _SpotlightPainter(this.targetRect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black.withValues(alpha: 1)
          ..blendMode = BlendMode.dstOut;

    // 先畫全遮罩
    canvas.saveLayer(
      Offset.zero & size,
      Paint()..color = Colors.black.withValues(alpha: 1),
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withValues(alpha: 0.7),
    );

    // 挖洞
    if (targetRect != null) {
      final rrect = RRect.fromRectAndRadius(targetRect!, Radius.circular(12));
      canvas.drawRRect(rrect, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect;
  }
}