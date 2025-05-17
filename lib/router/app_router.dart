import 'package:flutter/material.dart';
import 'package:my_flutter_framework/database/user_repository.dart';
import 'package:my_flutter_framework/pages/buttons/drag_confirm_button_demo_page.dart';
import 'package:my_flutter_framework/pages/home/dashboard_page.dart';
import 'package:my_flutter_framework/pages/login/login_page.dart';
import 'package:my_flutter_framework/pages/message/message_box_page.dart';
import 'package:my_flutter_framework/pages/ping/ping_test_page.dart';
import 'package:my_flutter_framework/pages/swipe_page_demo.dart';
import 'package:my_flutter_framework/pages/todo/todo_page.dart';
import 'package:my_flutter_framework/shared/pages/internal_error_page.dart';
import 'package:my_flutter_framework/shared/pages/not_found_page.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_framework/pages/image_upload_demo_page.dart';
import 'package:my_flutter_framework/pages/image_compress_demo_page.dart';
import 'package:my_flutter_framework/pages/ping/ping_devices_page.dart';

typedef RouteBuilder =
    Widget Function(BuildContext context, GoRouterState state);

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static const String indexRoute = '/dashboard';
  static const String loginRoute = '/login';
  static const String initialRoute = loginRoute;

  static final Map<String, RouteBuilder> routes = {
    loginRoute: (context, state) => const LoginPage(),
    indexRoute: (context, state) => const DashboardPage(),
    '/todo': (context, state) => const TodoPage(),
    '/message_box': (context, state) => const MessageBoxPage(),
    '/drag_confirm': (context, state) => const DragConfirmButtonDemoPage(),
    '/swipe_page_demo': (context, state) => const SwipePageDemo(),
    '/image_upload_demo': (context, state) => const ImageUploadDemoPage(),
    '/image_compress_demo': (context, state) => const ImageCompressDemoPage(),
    '/ping_tool': (context, state) => const PingTestPage(),
    '/ping_devices': (context, state) => const PingDevicesPage(),
    '/500':
        (context, state) => const InternalErrorPage(redirectPath: indexRoute),
  };

  static final GoRouter appRouter = GoRouter(
    initialLocation: initialRoute,
    navigatorKey: navigatorKey,
    routes:
        routes.entries.map((entry) {
          final path = entry.key;
          final builder = entry.value;
          return GoRoute(path: path, builder: builder);
        }).toList(),
    errorBuilder: (context, state) {
      return const NotFoundPage(redirectPath: indexRoute);
    },
    redirect: (context, state) async {
      final path = state.fullPath;
      // 1. 若路徑不存在於 routes，交由 errorBuilder 處理 404
      if (!routes.keys.contains(path)) {
        return null;
      }
      // 2. 若在白名單內，直接通過
      if (whiteList.contains(path)) {
        return null;
      }
      // 3. 其餘路徑需驗證登入狀態
      final isLoggedIn = await UserRepository.isTokenValid();
      final loggingIn = path == loginRoute;
      if (!isLoggedIn && !loggingIn) {
        // 未登入且不在登入頁，導向登入頁
        return loginRoute;
      }
      if (isLoggedIn && loggingIn) {
        // 已登入但在登入頁，導向 dashboard
        return indexRoute;
      }
      // 其他情況不重導
      return null;
    },
    refreshListenable: ValueNotifier(0),
  );

  static final Map<String, String> menuNames = {
    '/login': 'Login',
    '/dashboard': 'Dashboard',
    '/todo': 'Todo',
    '/message_box': 'Message Box',
    '/drag_confirm': 'Drag Confirm Button',
    '/swipe_page_demo': 'Swipe Page Demo',
    '/image_upload_demo': 'Image Upload Demo',
    '/image_compress_demo': 'Image Compress Demo',
    '/ping_tool': 'Ping Tool',
    '/ping_devices': 'Ping Devices',
  };

  static final List<String> hiddenMenus = ['/login'];

  /// 白名單
  static final List<String> whiteList = ['/login', '/500'];
}
