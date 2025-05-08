import 'package:flutter/material.dart';
import 'package:my_flutter_framework/pages/buttons/drag_confirm_button_demo_page.dart';
import 'package:my_flutter_framework/pages/home/dashboard_page.dart';
import 'package:my_flutter_framework/pages/login/login_page.dart';
import 'package:my_flutter_framework/pages/message/message_box_page.dart';
import 'package:my_flutter_framework/pages/todo/todo_page.dart';


class AppRouter {
  static const String initialRoute = '/login';

  static final Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginPage(),
    '/dashboard': (context) => const DashboardPage(),
    '/todo': (context) => const TodoPage(),
    '/message_box': (context) => const MessageBoxPage(),
    '/drag_confirm': (context) => const DragConfirmButtonDemoPage(),
  };

  static final Map<String, String> menuNames = {
    '/login': 'Login',
    '/dashboard': 'Dashboard',
    '/todo': 'Todo',
    '/message_box': 'Message Box',
    '/drag_confirm': 'Drag Confirm Button',
  };

  static final List<String> hiddenMenus = [
    '/login',
  ];
}