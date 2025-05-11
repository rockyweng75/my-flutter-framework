import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/pages/layout/main_layout_page.dart';
import 'package:my_flutter_framework/shared/components/buttons/drag_confirm_button.dart';
import 'package:my_flutter_framework/shared/components/reusable_notification.dart';
import 'package:my_flutter_framework/shared/components/tutorial/gesture_type.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_button.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_step.dart';
import 'package:my_flutter_framework/shared/utils/print_type.dart';

class DragConfirmButtonDemoPage extends ConsumerStatefulWidget {
  const DragConfirmButtonDemoPage({super.key});

  @override
  ConsumerState<DragConfirmButtonDemoPage> createState() =>
      _DragConfirmButtonDemoPageState();
}

class _DragConfirmButtonDemoPageState
    extends MainLayoutPage<DragConfirmButtonDemoPage> {
  // DragConfirmButton 對應的 GlobalKey 註冊
  final Map<String, GlobalKey> _dragButtonKeys = {
    'dragConfirmButton': GlobalKey(),
    'dragConfirmAndCancelButton': GlobalKey(),
    'dragConfirmLeftAndCacelButton': GlobalKey(),
    'dragConfirmWithCustomIconButton': GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    // 註冊到全域 registry
    _dragButtonKeys.forEach((id, key) {
      globalWidgetRegistry[id] = key;
    });
  }

  @override
  Widget buildContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Drag the button to confirm',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildDragConfirmButton(context),
          const SizedBox(height: 20),
          const Text(
            'Drag Confirm and Cancel Button',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildDragConfirmAndCancelButton(context),
          const SizedBox(height: 20),
          const Text(
            'Drag Left Confirm Button',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildDragConfirmLeftAndCacelButton(context),
          const SizedBox(height: 20),
          const Text(
            'Drag Button with Custom Confirm Icon',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildDragConfirmWithCustomIconButton(context),
        ],
      ),
    );
  }

  Widget _buildDragConfirmButton(BuildContext context) {
    return DragConfirmButton(
      key: _dragButtonKeys['dragConfirmButton'],
      label: 'Slide to Confirm',
      onConfirm: () {
        ReusableNotification(
          context,
        ).show('Confirmed!', type: PrintType.success);
      },
      confirmOnLeft: false,
    );
  }

  Widget _buildDragConfirmAndCancelButton(BuildContext context) {
    return DragConfirmButton(
      key: _dragButtonKeys['dragConfirmAndCancelButton'],
      label: 'Slide to Confirm',
      onConfirm: () {
        ReusableNotification(
          context,
        ).show('Confirmed!', type: PrintType.success);
      },
      onCancel: () {
        ReusableNotification(
          context,
        ).show('Cancelled!', type: PrintType.danger);
      },
      confirmOnLeft: false,
    );
  }

  Widget _buildDragConfirmLeftAndCacelButton(BuildContext context) {
    return DragConfirmButton(
      key: _dragButtonKeys['dragConfirmLeftAndCacelButton'],
      label: 'Slide Left to Confirm',
      onConfirm: () {
        ReusableNotification(
          context,
        ).show('Confirmed by Sliding Left!', type: PrintType.success);
      },
      onCancel: () {
        ReusableNotification(context).show('Cancelled', type: PrintType.danger);
      },
      confirmOnLeft: true,
    );
  }

  Widget _buildDragConfirmWithCustomIconButton(BuildContext context) {
    return DragConfirmButton(
      key: _dragButtonKeys['dragConfirmWithCustomIconButton'],
      label: 'Slide to Confirm',
      onConfirm: () {
        ReusableNotification(
          context,
        ).show('Confirmed with Custom Icon!', type: PrintType.success);
      },
      confirmIcon: const Icon(Icons.thumb_up, color: Colors.blue, size: 40),
      onCancel: () {
        ReusableNotification(
          context,
        ).show('Cancelled with Custom Icon!', type: PrintType.danger);
      },
      cancelIcon: const Icon(Icons.thumb_down, color: Colors.red, size: 40),
    );
  }

  @override
  List<TutorialStep>? getTutorialSteps(BuildContext context) {
    return tutorialSteps;
  }

  final List<TutorialStep> tutorialSteps = [
    TutorialStep(
      title: '拖曳確認按鈕教學',
      description: '這個頁面展示了如何使用拖曳確認按鈕，點擊右上角問號可隨時查看教學。',
    ),
    TutorialStep(
      title: '拖曳確認按鈕',
      description: '這個按鈕需要拖曳到右側才能確認。',
      targetWidgetId: 'dragConfirmButton', 
      gestureType: GestureType.dragRight
    ),
    TutorialStep(
      title: '拖曳確認與取消按鈕',
      description: '這個按鈕可以拖曳到右側確認或左側取消。',
      targetWidgetId: 'dragConfirmAndCancelButton', 
      gestureType: GestureType.dragRight
    ),
    TutorialStep(
      title: '拖曳左側確認按鈕',
      description: '這個按鈕需要拖曳到左側才能確認。',
      targetWidgetId: 'dragConfirmLeftAndCacelButton', 
      gestureType: GestureType.dragLeft
    ),
    TutorialStep(
      title: '自訂圖示的拖曳確認按鈕',
      description: '這個按鈕可以自訂確認和取消的圖示。',
      targetWidgetId: 'dragConfirmWithCustomIconButton',
      gestureType: GestureType.dragRight
    ),
  ];
}
