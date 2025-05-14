import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_framework/api/logout/logout_service.dart';
import 'package:my_flutter_framework/database/user_repository.dart';
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
                .map((entry) {
                  final isSelected = ModalRoute.of(context)?.settings.name == entry.key;
                  return ListTile(
                    title: Text(
                      entry.value,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColor.drawerSelectedText : AppColor.menuText,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: AppColor.drawerSelectedBackground,
                    onTap: () {
                      if (!isSelected) {
                        context.go(entry.key);
                      }
                    },
                  );
                }),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                final logoutService = LogoutService();
                await logoutService.logout();
                await UserRepository.clearUser();
                if (!context.mounted) return;
                // Navigator.pushReplacementNamed(context, '/login');
                // 使用 GoRouter 進行導航
                context.go('/login');
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