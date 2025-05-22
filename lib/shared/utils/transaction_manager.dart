import 'package:flutter/material.dart';
import 'package:my_flutter_framework/shared/components/loading/full_loading.dart';
class TransactionManager {
  final BuildContext context;

  TransactionManager(this.context);

  Future<T?> execute<T>(Future<T> Function() action) async {
    _showLoading();
    try {
      final result = await action(); // 執行非同步請求
      return result; // 回傳結果
    } catch (e) {
      rethrow; // 捕捉錯誤並重新拋出
    } finally {
      _hideLoading(); // 確保 loading 被隱藏
    }
  }

  void _showLoading() {
    FullLoading.show(context); // 顯示全螢幕 loading
  }

  void _hideLoading() {
    FullLoading.hide(); // 隱藏全螢幕 loading
  }

}