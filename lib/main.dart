import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_flutter_framework/api/http_client.dart';
import 'package:my_flutter_framework/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
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

  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();

  runApp(
    ProviderScope( // 全局註冊 Riverpod
      overrides: [
        httpClientProvider.overrideWithValue(
          HttpClient(dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000'),
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: AppRouter.appRouter,
    );


    // return MaterialApp(
    //   title: 'My Flutter Framework',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   initialRoute: AppRouter.initialRoute,
    //   routes: AppRouter.routes,
    // );
  }
}
