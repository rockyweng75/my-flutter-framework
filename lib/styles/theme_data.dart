import 'package:flutter/material.dart';
import 'package:my_flutter_framework/styles/app_color.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: AppColor.primary,
  scaffoldBackgroundColor: AppColor.menuBackground,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: AppColor.primary,
    secondary: AppColor.info,
    surface: AppColor.background,
    error: AppColor.danger,
    // 自訂 success 與 warning
    brightness: Brightness.light,
    // ignore: invalid_annotation_target
    // ignore: deprecated_member_use
  ),
).copyWith(
  // 透過 extension 或 copyWith 增加自訂色彩
  extensions: <ThemeExtension<dynamic>>[
    const CustomColors(success: AppColor.success, warning: AppColor.warning),
  ],
);

final ThemeData appDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColor.primaryDark,
  scaffoldBackgroundColor: AppColor.secondaryDark,
  colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
    primary: AppColor.primaryDark,
    secondary: AppColor.infoDark,
    surface: AppColor.backgroundDark,
    error: AppColor.dangerDark,
    // 自訂 success 與 warning
    brightness: Brightness.dark,
  ),
).copyWith(
  extensions: <ThemeExtension<dynamic>>[
    const CustomColors(success: AppColor.successDark, warning: AppColor.warningDark),
  ],
);

// 定義 ThemeExtension 以支援 success/warning
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color? success;
  final Color? warning;
  const CustomColors({this.success, this.warning});

  @override
  CustomColors copyWith({Color? success, Color? warning}) =>
      CustomColors(success: success ?? this.success, warning: warning ?? this.warning);

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      success: Color.lerp(success, other.success, t),
      warning: Color.lerp(warning, other.warning, t),
    );
  }
}

extension CustomColorScheme on ColorScheme {
  Color? get success => ThemeExtensionGetter._get(this)?.success;
  Color? get warning => ThemeExtensionGetter._get(this)?.warning;
}

class ThemeExtensionGetter {
  static CustomColors? _get(ColorScheme scheme) {
    // 這裡假設 context 取不到，只能用 ThemeData 取 extension
    // 但在 widget 內可直接 Theme.of(context).extension<CustomColors>()
    // 所以這裡僅作為語法糖
    final theme = ThemeData(brightness: scheme.brightness, colorScheme: scheme);
    return theme.extension<CustomColors>();
  }
}