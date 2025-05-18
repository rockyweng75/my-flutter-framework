import 'package:flutter/material.dart';
import 'package:my_flutter_framework/styles/app_color.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: AppColor.primary,
  scaffoldBackgroundColor: AppColor.menuBackground,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: AppColor.primary,
    secondary: AppColor.info,
    // surface: AppColor.background,
    error: AppColor.danger,
    // 自訂 success 與 warning
    // brightness: Brightness.light,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black87),
    bodySmall: TextStyle(fontSize: 12.0, color: Colors.black54),
    titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
    titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black87),
    titleSmall: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black54),
    labelLarge: TextStyle(fontSize: 16.0, color: Colors.black),
    labelMedium: TextStyle(fontSize: 14.0, color: Colors.black87),
    labelSmall: TextStyle(fontSize: 12.0, color: Colors.black54),
    displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.black),
    displayMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.black87),
    displaySmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black54),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2.0),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColor.primary,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
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
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16.0, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white70),
    bodySmall: TextStyle(fontSize: 12.0, color: Colors.white60),
    titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
    titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white70),
    titleSmall: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white60),
    labelLarge: TextStyle(fontSize: 16.0, color: Colors.white),
    labelMedium: TextStyle(fontSize: 14.0, color: Colors.white70),
    labelSmall: TextStyle(fontSize: 12.0, color: Colors.white60),
    displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.white70),
    displaySmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white60),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white70),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColor.primaryDark,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
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