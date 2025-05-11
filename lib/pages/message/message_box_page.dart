import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/pages/layout/main_layout_page.dart';
import 'package:my_flutter_framework/shared/components/message_box.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_button.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_step.dart';
import 'package:my_flutter_framework/shared/utils/print_type.dart';
import 'package:my_flutter_framework/styles/app_color.dart';

// 引入 ValueKey 以便於 id 註冊
class MessageBoxPage extends ConsumerStatefulWidget {
  const MessageBoxPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MessageBoxPageState();
  }
}

class _MessageBoxPageState extends MainLayoutPage<MessageBoxPage> {
  // 註冊 GlobalKey
  final GlobalKey _listKey = GlobalKey();
  late final Map<String, GlobalKey> _buttonKeys;
  late final Map<String, GlobalKey> _cardKeys;

  @override
  void initState() {
    super.initState();
    _registerKeys();
  }

  void _registerKeys() {
    _buttonKeys = {
      for (var type in PrintType.values) _buttonKeyId(type): GlobalKey(),
    };
    _cardKeys = {
      for (var type in PrintType.values) _cardKeyId(type): GlobalKey(),
    };
    globalWidgetRegistry['messageBoxTypeList'] = _listKey;
    _buttonKeys.forEach((id, key) {
      globalWidgetRegistry[id] = key;
    });
    _cardKeys.forEach((id, key) {
      globalWidgetRegistry[id] = key;
    });
  }

  String _buttonKeyId(PrintType type) =>
      type == PrintType.danger
          ? 'showMessageBoxButtonDanger'
          : 'showMessageBoxButton_${type.toString().split('.').last}';

  String _cardKeyId(PrintType type) =>
      type == PrintType.danger
          ? 'dangerMessageBox'
          : 'messageBox_${type.toString().split('.').last}';

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
            // 用 key 包住 ListView
            child: _buildCardListTile(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCardListTile(context) {
    List<PrintType> types = PrintType.values;
    return ListView.builder(
      key: _listKey, // 用 GlobalKey
      itemCount: types.length,
      itemBuilder: (context, index) {
        return _buildCardByPrintType(context, types[index]);
      },
    );
  }

  Widget _buildCardByPrintType(context, PrintType type) {
    final String cardId = _cardKeyId(type);
    final String btnId = _buttonKeyId(type);
    return Card(
      color: AppColor.cardOddBackground,
      key: _cardKeys[cardId], // 用 GlobalKey
      child: ListTile(
        title: Row(
          children: [
            PrintTypeUtil.getTypeIcon(type: type),
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
          key: _buttonKeys[btnId], // 用 GlobalKey
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
                        Navigator.of(context).pop();
                        print('Danger confirmed');
                      }
                      : null,
              onCancel:
                  type == PrintType.danger
                      ? () {
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

  @override
  List<TutorialStep>? getTutorialSteps(BuildContext context) {
    return messageBoxTutorialSteps;
  }

  final List<TutorialStep> messageBoxTutorialSteps = [
    TutorialStep(
      title: '訊息盒教學',
      description: '本頁展示各種訊息盒(Message Box)的用法，點擊右上角問號可隨時查看教學。',
      // imageAssetPath: 'assets/tutorial/message_box_intro.png', // 可用頁面截圖或移除
    ),
    TutorialStep(
      title: '訊息盒類型列表',
      description: '這裡列出所有支援的訊息盒類型（info、success、warning、danger）。',
      targetWidgetId: 'messageBoxTypeList', // 請在對應 ListView 註冊 id
    ),
    TutorialStep(
      title: '顯示訊息盒',
      description: '點擊 Show 按鈕會跳出對應類型的訊息盒。',
      targetWidgetId: 'showMessageBoxButton', // 請在對應 ElevatedButton 註冊 id
    ),
    TutorialStep(
      title: '危險訊息盒',
      description: 'danger 類型訊息盒會有確認與取消按鈕，適合用於重要操作。',
      targetWidgetId: 'dangerMessageBox', // 請在 danger 類型訊息盒註冊 id
    ),
  ];
}
