import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:my_flutter_framework/shared/components/custom_button.dart';
import 'package:my_flutter_framework/shared/models/custom_style.dart';
import 'package:my_flutter_framework/shared/pages/simple_query_form_page.dart';

class OrderConfig {
  final String name;
  final String label;
  OrderConfigType? initialValue;

  OrderConfig({
    required this.name,
    required this.label,
    required this.initialValue,
  });

  Widget getOrderField(
    BuildContext context,
    GlobalKey<FormBuilderState> formKey,
    SimpleQueryFormPageState state
  ) {
    if (initialValue != null) {
      // 同步初始值到表單資料
      FormBuilder.of(context)?.fields[name]?.didChange(
        initialValue == OrderConfigType.asc ? 'asc' : 'desc',
      );
    }
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return CustomButton(
          label: label,
          type: ButtonType.mixed,
          onTap: () {
            if (state.mounted) {
              setState(() {
                final newValue = !(initialValue == OrderConfigType.asc);
                initialValue =
                    newValue ? OrderConfigType.asc : OrderConfigType.desc;
              });
            }
            // 更新表單狀態
            FormBuilder.of(context)?.save();
            // 在表單內填入 order
            formKey.currentState?.fields['order']?.didChange({
              name: initialValue == OrderConfigType.asc ? 'asc' : 'desc',
            });
          },
          icon:
              initialValue != null
                  ? Icon(
                    initialValue == OrderConfigType.asc
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                  )
                  : null,
          style: CustomStyle(
            backgroundColor: Colors.white,
            textStyle: TextStyle(color: Colors.black),
          ),
        );
      },
    );
  }
}

enum OrderConfigType { asc, desc }
