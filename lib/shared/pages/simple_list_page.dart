import 'dart:ui';

import 'package:flutter/material.dart';
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

  const SimpleListPage({
    super.key,
    required this.items,
    required this.scrollController,
    required this.isLoading,
    required this.isScreenLocked,
    required this.onLoadMore,
    required this.onItemTap,
    required this.rowBuilder,
  });

  T buildQueryForm<T extends SimpleQueryFormPage>(BuildContext context);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // 父容器的背景色
      child: Stack(
        children: [
          Material(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  SizedBox(
                    height: 100.0,
                    child: buildQueryForm<SimpleQueryFormPage>(context),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: items.length + 1,
                      itemBuilder: (context, index) {
                        if (index == items.length) {
                          return isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : const SizedBox();
                        }
                        final item = items[index];
                        return rowBuilder(context, item);
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
