import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_flutter_framework/shared/components/tutorial/gesture_type.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_button.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_step.dart';
import 'package:my_flutter_framework/shared/pages/simple_query_form_page.dart';

typedef CallbackWithParam = void Function(Map<String, dynamic>? params);

abstract class SimpleListPage extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final ScrollController scrollController;
  final bool isLoading;
  final bool isScreenLocked;
  final CallbackWithParam onLoadMore;
  final Function(Map<String, dynamic>) onItemTap;
  final Widget Function(BuildContext, Map<String, dynamic>) rowBuilder;
  final GlobalKey _listKey = GlobalKey(debugLabel: 'simpleList');
  // 新增：動態產生每個 list item 的 key
  final Map<int, GlobalKey> _itemKeys = {};

  SimpleListPage({
    super.key,
    required this.items,
    required this.scrollController,
    required this.isLoading,
    required this.isScreenLocked,
    required this.onLoadMore,
    required this.onItemTap,
    required this.rowBuilder,
  }) {
    globalWidgetRegistry['simpleList'] = _listKey;
    // 移除原本的 simpleListItem 註冊，改為動態註冊每一列
  }

  static List<TutorialStep> get tutorialSteps => [
    TutorialStep(
      title: '資料列表',
      description: '滑動列表可查看更多資料。',
      targetWidgetId: 'simpleList',
      gestureType: GestureType.dragDown,
    ),
    TutorialStep(
      title: '資料列',
      description: '點擊資料列可進入詳細頁面。',
      targetWidgetId: 'simpleListItem',
      gestureType: GestureType.tap,
    ),
  ];

  T buildQueryForm<T extends SimpleQueryFormPage>(BuildContext context);

  /// 可覆寫的無資料區塊
  Widget buildEmptyWidget(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('無資料', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final queryFormPage = buildQueryForm<SimpleQueryFormPage>(context);

    return Container(
      key: _listKey,
      color: Theme.of(context).colorScheme.surface, // 父容器的背景色
      child: Stack(
        children: [
          Material(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  SizedBox(height: 100.0, child: queryFormPage),
                  Expanded(
                    child:
                        items.isEmpty
                            ? buildEmptyWidget(context)
                            : ListView.builder(
                              controller: scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: items.length + 1,
                              itemBuilder: (context, index) {
                                if (index == items.length) {
                                  return isLoading
                                      ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                      : const SizedBox();
                                }
                                final item = items[index];
                                // 為每個 item 註冊 key
                                _itemKeys[index] = GlobalKey(
                                  debugLabel: 'simpleListItem_$index',
                                );
                                globalWidgetRegistry['simpleListItem_$index'] =
                                    _itemKeys[index]!;
                                return Container(
                                  key: _itemKeys[index],
                                  child: rowBuilder(context, item),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),
          if (isScreenLocked)
            Container(
              color: Colors.black.withValues(
                colorSpace: ColorSpace.sRGB,
                alpha: 0.5,
              ), // 半透明黑色遮罩
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
