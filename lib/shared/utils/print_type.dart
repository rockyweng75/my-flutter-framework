import 'package:flutter/material.dart';
import 'package:my_flutter_framework/styles/app_color.dart';

enum PrintType { primary, success, info, warning, danger }

class PrintTypeUtil {
  static String getTypeName(PrintType type) {
    switch (type) {
      case PrintType.primary:
        return 'Primary';
      case PrintType.success:
        return 'Success';
      case PrintType.info:
        return 'Info';
      case PrintType.warning:
        return 'Warning';
      case PrintType.danger:
        return 'Danger';
    }
  }
  
  static Icon getTypeIcon(PrintType type) {
    switch (type) {
      case PrintType.primary:
        return const Icon(Icons.info, color: AppColor.info);
      case PrintType.success:
        return const Icon(Icons.check_circle, color: AppColor.success);
      case PrintType.info:
        return const Icon(Icons.info_outline, color: AppColor.primary);
      case PrintType.warning:
        return const Icon(Icons.warning, color: AppColor.warning);
      case PrintType.danger:
        return const Icon(Icons.error, color: AppColor.danger);
    }
  }

  static Color getTypeColor(PrintType type) {
    switch (type) {
      case PrintType.primary:
        return AppColor.info;
      case PrintType.success:
        return AppColor.success;
      case PrintType.info:
        return AppColor.primary;
      case PrintType.warning:
        return AppColor.warning;
      case PrintType.danger:
        return AppColor.danger;
    }
  }
}
