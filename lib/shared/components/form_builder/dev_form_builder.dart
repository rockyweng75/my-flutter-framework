import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_framework/shared/utils/json_helper.dart';

class DevFormBuilder extends FormBuilder {
  final bool testMode;

  DevFormBuilder({
    super.key,
    required super.child,
    this.testMode = false,
    super.onChanged,
    super.autovalidateMode,
    super.onPopInvokedWithResult,
    super.initialValue,
    super.skipDisabled,
    super.enabled,
    super.clearValueOnUnregister,
    super.canPop,
  });

  @override
  FormBuilderState createState() => _DevFormBuilderState();
}

class _DevFormBuilderState extends FormBuilderState {
  @override
  Widget build(BuildContext context) {
    final formWidget = super.build(context);

    if ((widget as DevFormBuilder).testMode) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.topRight,
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Form Data'),
                      content: SingleChildScrollView(
                        child: Text(
                          JsonHelper.mapToJson(
                            fields.map((key, value) => MapEntry(
                              key,
                              value.value is DateTime
                                  ? (value.value as DateTime).toIso8601String()
                                  : value.value is DateTimeRange
                                      ? {
                                          'start': (value.value as DateTimeRange)
                                              .start
                                              .toIso8601String(),
                                          'end': (value.value as DateTimeRange)
                                              .end
                                              .toIso8601String(),
                                        }
                                      : value.value,
                            )),
                          ),
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          formWidget, // 移除 Expanded，直接返回表單內容
        ],
      );
    }

    return formWidget;
  }
}