import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:my_flutter_framework/router/app_router.dart';

class ErrorHandler {
  final Logger _logger = Logger();

  ErrorHandler() {
    FlutterError.onError = (FlutterErrorDetails error) {
      FlutterError.presentError(error); // 標記已處理
      _logger.e('FlutterError: ${error.exceptionAsString()}');
      _logger.e('StackTrace: ${error.stack}');
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        ctx.go('/500');
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        ctx.go('/500');
      }
      return true; // 已處理錯誤
    };
  }
}
