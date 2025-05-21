import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:my_flutter_framework/api/ai_client.dart';
import 'package:my_flutter_framework/api/http_client.dart';
import 'package:my_flutter_framework/handlers/error_handler.dart';
import 'package:my_flutter_framework/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/styles/theme_data.dart';

class CustomScrollBehavior extends ScrollBehavior {
  // @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) {
    return child; // 移除滾動條樣式，模仿 iOS 滾動效果
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(); // 啟用 iOS 式彈性滾動
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse, // 支持滑鼠拖動
  };
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Logger logger = Logger();

  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();

  ErrorHandler();

  // 優先使用 dart-define，否則 fallback 到 dotenv
  final aiUrl = const String.fromEnvironment('AI_URL', defaultValue: '')
      .isNotEmpty
      ? const String.fromEnvironment('AI_URL')
      : dotenv.env['AI_URL'] ?? 'http://localhost:3000';

  final aiKey = const String.fromEnvironment('AI_KEY', defaultValue: '')
      .isNotEmpty
      ? const String.fromEnvironment('AI_KEY')
      : dotenv.env['AI_KEY'] ?? 'your_api_key';

  final apiBaseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: '')
      .isNotEmpty
      ? const String.fromEnvironment('API_BASE_URL')
      : dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  runApp(
    ProviderScope(
      overrides: [
        httpClientProvider.overrideWithValue(
          HttpClient(apiBaseUrl),
        ),
        aiClientProvider.overrideWithValue(
          AiClient(aiUrl, aiKey),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scrollBehavior: CustomScrollBehavior(),
      title: 'My Flutter Framework',
      theme: appTheme,
      darkTheme: appDarkTheme,
      routerConfig: AppRouter.appRouter,
      // 不要再用 builder 包 Navigator，讓 GoRouter 處理所有路由
    );
  }
}
