import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/api/swipePage/swipe_page_service.dart';
import 'package:my_flutter_framework/mock/mock_swipe_page_service.dart';

final swipePageServiceProvider = Provider<ISwipePageService>((ref) {
  // 判斷是否為測試環境
  if (kDebugMode) {
    return MockSwipePageService();
  } else {
    return SwipePageService();
  }
});

abstract class ISwipePageService {
  /// 取得頁面數量
  Future<int> getPageCount();
  /// 載入更多頁面，回傳最新頁面數
  Future<int> loadMorePages();
}