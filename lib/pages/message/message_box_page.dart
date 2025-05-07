import 'package:flutter/material.dart';
import 'package:my_flutter_framework/shared/components/message_box.dart';
import 'package:my_flutter_framework/shared/utils/print_type.dart';
import 'package:my_flutter_framework/styles/app_color.dart';

class MessageBoxPage extends StatelessWidget {
  const MessageBoxPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Box'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildCardListTile(context),
      )
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
            PrintTypeUtil.getTypeIcon(type),
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
        subtitle: Text('This is a ${type.toString().split('.').last.toLowerCase()} message box.'),
        trailing: ElevatedButton(
          onPressed: () {
            showMessageBox(
              context: context,
              title: type.toString().split('.').last,
              message: 'This is a ${type.toString().split('.').last.toLowerCase()} message box.',
              type: type, 
            );
          },
          child: const Text('Show'),
        ),
      ),
    );

  }
}