// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_flutter_framework/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    // await dotenv.load(fileName: ".env");
    final testDir = Directory.systemTemp.createTempSync();
    Hive.init(testDir.path);
    await tester.pumpWidget(ProviderScope(child: const MyApp()));

    // Verify that the app renders the initial route without errors.
    // expect(find.text('Welcome to the Dashboard!'), findsOneWidget);
  });
}
