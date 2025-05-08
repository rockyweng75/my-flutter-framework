import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/pages/layout/main_layout_page.dart';
import 'package:my_flutter_framework/shared/components/message_box.dart';
import 'package:my_flutter_framework/shared/utils/print_type.dart';
import 'package:my_flutter_framework/styles/app_color.dart';

class MessageBoxPage extends ConsumerStatefulWidget {
  const MessageBoxPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MessageBoxPageState();
  }
}

class _MessageBoxPageState extends MainLayoutPage<MessageBoxPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Message Box 說明',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '此頁面展示了不同類型的 Message Box，您可以點擊每個按鈕來查看對應的訊息框。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: _buildCardListTile(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCardListTile(context) {
    List<PrintType> types = PrintType.values;
    return ListView.builder(
      itemCount: types.length,
      itemBuilder: (context, index) {
        return _buildCardByPrintType(context, types[index]);
      },
    );
  }

  Widget _buildCardByPrintType(context, PrintType type) {
    return Card(
      color: AppColor.cardOddBackground,
      child: ListTile(
        title: Row(
          children: [
            PrintTypeUtil.getTypeIcon(
              type: type,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                type.toString().split('.').last,
                style: TextStyle(
                  color: PrintTypeUtil.getTypeColor(type),
                  fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        subtitle: Text(
          type == PrintType.danger
              ? 'This is a ${type.toString().split('.').last.toLowerCase()} message box with Confirm and Cancel buttons.'
              : 'This is a ${type.toString().split('.').last.toLowerCase()} message box.',
        ),
        trailing: ElevatedButton(
          onPressed: () {
            showMessageBox(
              context: context,
              title: type.toString().split('.').last,
              message:
                  type == PrintType.danger
                      ? 'This is a ${type.toString().split('.').last.toLowerCase()} message box with Confirm and Cancel buttons.'
                      : 'This is a ${type.toString().split('.').last.toLowerCase()} message box.',
              type: type,
              onConfirm:
                  type == PrintType.danger
                      ? () {
                        // 確認按鈕邏輯
                        Navigator.of(context).pop();
                        print('Danger confirmed');
                      }
                      : null,
              onCancel:
                  type == PrintType.danger
                      ? () {
                        // 取消按鈕邏輯
                        Navigator.of(context).pop();
                        print('Danger cancelled');
                      }
                      : null,
            );
          },
          child: const Text('Show'),
        ),
      ),
    );
  }
}
