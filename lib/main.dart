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

  runApp(
    ProviderScope(
      // 全局註冊 Riverpod
      overrides: [
        httpClientProvider.overrideWithValue(
          HttpClient(dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000'),
        ),
        aiClientProvider.overrideWithValue(
          AiClient(dotenv.env['AI_URL'] ?? 'http://localhost:3000', dotenv.env['AI_KEY'] ?? 'your_api_key'),
        ),
      ],
      child: MyApp(), // 這裡用 MyApp
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
