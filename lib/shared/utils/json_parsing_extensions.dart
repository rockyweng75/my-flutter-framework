extension JsonParsingExtensions on Object? {
  static bool debug = true; // 可切換是否顯示 log

  void _log(String field, dynamic value, String expectedType) {
    if (debug) {
      print('[JsonParsingExtensions] ⚠️ 無法解析欄位 "$field" 的值 "$value"，預期為 $expectedType');
    }
  }

  int toInt([int fallback = 0, String field = '']) {
    try {
      if (this is int) return this as int;
      if (this is String) return int.parse(this as String);
    } catch (_) {
      _log(field, this, 'int');
    }
    return fallback;
  }

  double toDouble([double fallback = 0.0, String field = '']) {
    try {
      if (this is double) return this as double;
      if (this is int) return (this as int).toDouble();
      if (this is String) return double.parse(this as String);
    } catch (_) {
      _log(field, this, 'double');
    }
    return fallback;
  }

  String toStringValue([String fallback = '', String field = '']) {
    if (this == null) {
      _log(field, this, 'String');
      return fallback;
    }
    return this.toString();
  }

  bool toBool([bool fallback = false, String field = '']) {
    try {
      if (this is bool) return this as bool;
      if (this is String) {
        final lower = (this as String).toLowerCase();
        if (lower == 'true') return true;
        if (lower == 'false') return false;
      }
      if (this is int) return (this as int) != 0;
    } catch (_) {
      _log(field, this, 'bool');
    }
    return fallback; // 確保在所有無效情況下回傳 fallback
  }
}
