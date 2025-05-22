import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/pages/layout/main_layout_page.dart';
import 'package:my_flutter_framework/shared/components/loading/reveal_progress_mask.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_step.dart';

class ProgressPage extends ConsumerStatefulWidget {
  const ProgressPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProgressPageState();
}

class _ProgressPageState extends MainLayoutPage<ProgressPage> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  void _startProgress() async {
    while (_progress < 1.0) {
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        _progress = (_progress + 0.1).clamp(0.0, 1.0);
      });
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    return RevealProgressMask(
      progress: _progress,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        color: Colors.blueGrey.shade100,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '自訂遮罩進度條範例',
              style: TextStyle(fontSize: 24, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Icon(Icons.hourglass_bottom, size: 64, color: Colors.blueGrey),
            const SizedBox(height: 24),
            Text(
              '目前進度：${(_progress * 100).toInt()}%',
              style: const TextStyle(fontSize: 20, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            const Text(
              '這是一個會隨進度揭露畫面的自訂遮罩效果。',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  List<TutorialStep>? getTutorialSteps(BuildContext context) {
    return loadingPageTutorialSteps;
  }

  final List<TutorialStep> loadingPageTutorialSteps = [
    TutorialStep(
      title: '讀取中頁面',
      description: '本頁展示一個簡單的讀取條(CircularProgressIndicator)。',
    ),
  ];
}
