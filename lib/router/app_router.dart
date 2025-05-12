import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:my_flutter_framework/database/user_repository.dart';
import 'package:my_flutter_framework/pages/buttons/drag_confirm_button_demo_page.dart';
import 'package:my_flutter_framework/pages/home/dashboard_page.dart';
import 'package:my_flutter_framework/pages/login/login_page.dart';
import 'package:my_flutter_framework/pages/message/message_box_page.dart';
import 'package:my_flutter_framework/pages/swipe_page_demo.dart';
import 'package:my_flutter_framework/pages/todo/todo_page.dart';
import 'package:go_router/go_router.dart';

typedef RouteBuilder =
    Widget Function(BuildContext context, GoRouterState state);

class AppRouter {
  final Logger _logger = Logger();

  static const String initialRoute = '/login';

  static final Map<String, RouteBuilder> routes = {
    '/login': (context, state) => const LoginPage(),
    '/dashboard': (context, state) => const DashboardPage(),
    '/todo': (context, state) => const TodoPage(),
    '/message_box': (context, state) => const MessageBoxPage(),
    '/drag_confirm': (context, state) => const DragConfirmButtonDemoPage(),
    '/swipe_page_demo': (context, state) => const SwipePageDemo(),
  };

  static final GoRouter appRouter = GoRouter(
    initialLocation: initialRoute,
    routes:
        routes.entries.map((entry) {
          final path = entry.key;
          final builder = entry.value;
          return GoRoute(path: path, builder: builder);
        }).toList(),
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: ${state.error}')),
      );
    },
    redirect: (context, state) async{
      var isLoggedIn = await UserRepository.isTokenValid();
      final loggingIn = state.fullPath == '/login';
      if (!isLoggedIn && !loggingIn) {
        // 未登入且不在登入頁，導向登入頁
        return '/login';
      }
      if (isLoggedIn && loggingIn) {
        // 已登入但在登入頁，導向 dashboard
        return '/dashboard';
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
  };

  static final List<String> hiddenMenus = ['/login'];
}
