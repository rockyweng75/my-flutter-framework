import 'package:flutter/material.dart';
import 'package:my_flutter_framework/api/logout/logout_service.dart';
import 'package:my_flutter_framework/pages/layout/notification/notification_button.dart';
import 'package:my_flutter_framework/router/app_router.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_button.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_step.dart';
import 'package:my_flutter_framework/styles/app_color.dart';
class MainLayout extends StatelessWidget {
  final Widget child;
  final Widget? floatingActionButton;
  final List<TutorialStep>? tutorialSteps;

  const MainLayout({
    required this.child, 
    this.floatingActionButton, 
    this.tutorialSteps,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppRouter.menuNames[ModalRoute.of(context)?.settings.name] ?? 'Main Layout'),
        actions: [
          if (tutorialSteps != null && (tutorialSteps?.isNotEmpty ?? false))
            TutorialButton(
              steps: tutorialSteps!,
            ), // 教學按鈕
          NotificationButton()
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: AppColor.drawerHeaderBackground,
              ),
              child: Text('Menu'),
            ),
            ...AppRouter.menuNames.entries
                .where((entry) => !AppRouter.hiddenMenus.contains(entry.key))
                .map((entry) => ListTile(
                      title: Text(entry.value), // 使用 menuNames 的值作為菜單名稱
                      onTap: () {
                        Navigator.pushReplacementNamed(context, entry.key);
                      },
                    )),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                final logoutService = LogoutService();
                await logoutService.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: child
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}