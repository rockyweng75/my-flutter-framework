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

  static Icon getTypeIcon({
    PrintType type = PrintType.primary,
    bool isLight = false,
  }) {
    switch (type) {
      case PrintType.primary:
        return Icon(
          Icons.info,
          color: isLight ? AppColor.infoLight : AppColor.info,
        );
      case PrintType.success:
        return Icon(
          Icons.check_circle,
          color: isLight ? AppColor.successLight : AppColor.success,
        );
      case PrintType.info:
        return Icon(
          Icons.info_outline,
          color: isLight ? AppColor.primaryLight : AppColor.primary,
        );
      case PrintType.warning:
        return Icon(
          Icons.warning,
          color: isLight ? AppColor.warningLight : AppColor.warning,
        );
      case PrintType.danger:
        return Icon(
          Icons.error,
          color: isLight ? AppColor.dangerLight : AppColor.danger,
        );
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
