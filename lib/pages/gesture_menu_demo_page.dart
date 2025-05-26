import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/pages/layout/main_layout_page.dart';
import 'package:my_flutter_framework/shared/components/menus/draggable_menu_button.dart';
import 'package:my_flutter_framework/shared/components/reusable_notification.dart';
import 'package:my_flutter_framework/shared/components/tutorial/gesture_type.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_button.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_step.dart';
import 'package:my_flutter_framework/shared/utils/print_type.dart';

class GestureMenuDemoPage extends ConsumerStatefulWidget {
  const GestureMenuDemoPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GestureMenuDemoPageState();
}

class _GestureMenuDemoPageState extends MainLayoutPage<GestureMenuDemoPage> {
  final GlobalKey _buttonKey = GlobalKey(debugLabel: 'gestureMenuButton');

  static final List<MenuItem> menuItems = [
    MenuItem(key: 'home', label: '首頁'),
    MenuItem(key: 'search', label: '搜尋'),
    MenuItem(key: 'settings', label: '設定'),
    MenuItem(key: 'about', label: '關於'),
  ];

  @override
  void initState() {
    super.initState();
    _registerKeys();
  }

  void _registerKeys() {
    globalWidgetRegistry['gestureMenuButton'] = _buttonKey;
  }

  void _onMenuItemSelected(BuildContext context, String key) {
    final String label = menuItems.firstWhere((item) => item.key == key).label;
    ReusableNotification(context).show(
      '選擇了: $label',
      type: PrintType.info,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DraggableMenuButton(
              key: _buttonKey,
              menuItems:
                  menuItems.map((item) {
                    return MenuItem(
                      key: item.key,
                      label: item.label,
                      onSelected: (key) => _onMenuItemSelected(context, key),
                    );
                  }).toList(),
              buttonSize: 80,
              arcSweep: 3.14159, // 半圓
              arcStart: DraggableMenuButton.kArcStartDown, // 往下
              backgroundRadiusRatio: 2.0,
            ),
          ],
        ),
        const SizedBox(height: 120),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '本頁展示可拖曳的圓形選單按鈕',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  List<TutorialStep> get gestureMenuTutorialSteps => [
    TutorialStep(
      title: '拖曳選單按鈕',
      description: '點擊並拖曳按鈕以顯示選單項目。',
      targetWidgetId: 'gestureMenuButton',
      gestureType: GestureType.dragDown,
    ),
    TutorialStep(
      title: '選擇項目',
      description: '拖曳按鈕至選單項目以選擇。',
      imageAssetPath: 'assets/tutorials/gesture_menu_select_item.png',
      gestureType: GestureType.dragDown,
    ),
  ];

  @override
  List<TutorialStep>? getTutorialSteps(BuildContext context) {
    return gestureMenuTutorialSteps;
  }
}
