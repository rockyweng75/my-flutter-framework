import 'package:flutter/material.dart';
import 'package:my_flutter_framework/pages/home/dashboard_page.dart';
import 'package:my_flutter_framework/pages/login/login_page.dart';
import 'package:my_flutter_framework/pages/todo/todo_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/login/login_service.dart';
import '../mock/mock_login_service.dart';

class AppRouter {
  static const String initialRoute = '/login';

  static final Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginPage(),
    '/dashboard': (context) => const DashboardPage(),
    '/todo': (context) => const TodoPage(),
  };

  static final Map<String, String> menuNames = {
    '/login': 'Login',
    '/dashboard': 'Dashboard',
    '/todo': 'Todo',
  };

  static final List<String> hiddenMenus = [
    '/login',
  ];
}