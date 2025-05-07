import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/pages/layout/main_layout.dart';


abstract class MainLayoutPage<T extends ConsumerStatefulWidget> extends ConsumerState<T> {
  Widget buildContent(BuildContext context);

  Widget? buildFloatingActionButton(BuildContext context) => null;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      floatingActionButton: buildFloatingActionButton(context),
      child: buildContent(context),
    );
  }
}