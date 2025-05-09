import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/pages/layout/main_layout_page.dart';
import 'package:my_flutter_framework/shared/components/buttons/drag_confirm_button.dart';
import 'package:my_flutter_framework/shared/components/reusable_notification.dart';
import 'package:my_flutter_framework/shared/utils/print_type.dart';

class DragConfirmButtonDemoPage extends ConsumerStatefulWidget {
  const DragConfirmButtonDemoPage({super.key});

  @override
  ConsumerState<DragConfirmButtonDemoPage> createState() =>
      _DragConfirmButtonDemoPageState();
}

class _DragConfirmButtonDemoPageState
    extends MainLayoutPage<DragConfirmButtonDemoPage> {
    

  @override
  Widget buildContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Drag the button to confirm',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildDragConfirmButton(context),
          const SizedBox(height: 20),
          const Text(
            'Drag Confirm and Cancel Button',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildDragConfirmAndCancelButton(context),
          const SizedBox(height: 20),
          const Text(
            'Drag Left Confirm Button',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildDragConfirmLeftAndCacelButton(context),
          const SizedBox(height: 20),
          const Text(
            'Drag Button with Custom Confirm Icon',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildDragConfirmWithCustomIconButton(context),
        ],
      ),
    );
  }

  Widget _buildDragConfirmButton(BuildContext context) {
    return DragConfirmButton(
      label: 'Slide to Confirm',
      onConfirm: () {
        ReusableNotification(
          context,
        ).show('Confirmed!', type: PrintType.success);
      },
      confirmOnLeft: false,
    );
  }

  Widget _buildDragConfirmAndCancelButton(BuildContext context) {
    return DragConfirmButton(
      label: 'Slide to Confirm',
      onConfirm: () {
        ReusableNotification(
          context,
        ).show('Confirmed!', type: PrintType.success);
      },
      onCancel: () {
        ReusableNotification(
          context,
        ).show('Cancelled!', type: PrintType.danger);
      },
      confirmOnLeft: false,
    );
  }

  Widget _buildDragConfirmLeftAndCacelButton(BuildContext context) {
    return DragConfirmButton(
      label: 'Slide Left to Confirm',
      onConfirm: () {
        ReusableNotification(
          context,
        ).show('Confirmed by Sliding Left!', type: PrintType.success);
      },
      onCancel: () {
        ReusableNotification(context).show('Cancelled', type: PrintType.danger);
      },
      confirmOnLeft: true,
    );
  }

  Widget _buildDragConfirmWithCustomIconButton(BuildContext context) {
    return DragConfirmButton(
      label: 'Slide to Confirm',
      onConfirm: () {
        ReusableNotification(
          context,
        ).show('Confirmed with Custom Icon!', type: PrintType.success);
      },
      confirmIcon: const Icon(Icons.thumb_up, color: Colors.blue, size: 40),
      onCancel: () {
        ReusableNotification(
          context,
        ).show('Cancelled with Custom Icon!', type: PrintType.danger);
      },
      cancelIcon: const Icon(Icons.thumb_down, color: Colors.red, size: 40),
    );
  }
}
