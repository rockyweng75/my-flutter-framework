import 'package:flutter/material.dart';
import 'package:my_flutter_framework/shared/full_width_card_action.dart';

/// 通用滑動卡片清單元件，僅負責渲染傳入的資料與互動，不含任何語意。
class SwipeCardList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Future<void> Function(Map<String, dynamic> item) onConfirm;
  final Future<void> Function(Map<String, dynamic> item) onCancel;
  final String? emptyText;
  final Widget Function(Map<String, dynamic> item) buildContent;

  const SwipeCardList({
    super.key,
    required this.items,
    required this.onConfirm,
    required this.onCancel,
    this.emptyText,
    required this.buildContent,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        emptyText ?? '無項目',
        style: const TextStyle(color: Colors.grey),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, idx) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final item = items[idx];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: FullWidthCardAction(
            onConfirm: () async => await onConfirm(item),
            onCancel: () async => await onCancel(item),
            confirmIcon: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 40,
            ),
            cancelIcon: const Icon(
              Icons.delete,
              color: Colors.red,
              size: 40,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: buildContent(item)
              // Stack(
              //   children: [
              //     // Align(
              //     //   alignment: Alignment.centerLeft,
              //     //   child: Column(
              //     //     crossAxisAlignment: CrossAxisAlignment.start,
              //     //     mainAxisAlignment: MainAxisAlignment.center,
              //     //     children: [
              //     //       Text(
              //     //         item['title'] ?? '無標題',
              //     //         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              //     //       ),
              //     //       if (item['description'] != null && item['description'].toString().isNotEmpty)
              //     //         Padding(
              //     //           padding: const EdgeInsets.only(top: 4.0),
              //     //           child: Text(
              //     //             item['description'],
              //     //             style: const TextStyle(fontSize: 14, color: Colors.black54),
              //     //             maxLines: 2,
              //     //             overflow: TextOverflow.ellipsis,
              //     //           ),
              //     //         ),
              //     //     ],
              //     //   ),
              //     // ),
              //     // Positioned(
              //     //   right: 12,
              //     //   bottom: 8,
              //     //   child: Text(
              //     //     item['dueDate'] != null
              //     //         ? '截止日期: ${item['dueDate']}'
              //     //         : '無截止日期',
              //     //     style: const TextStyle(fontSize: 13, color: Colors.grey),
              //     //   ),
              //     // ),
              //   ],
              // ),
            ),
          ),
        );
      },
    );
  }
}
