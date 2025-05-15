import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:my_flutter_framework/shared/components/form_builder/searchable_dropdown_field.dart';
import 'package:my_flutter_framework/shared/components/file_upload.dart';
import 'package:my_flutter_framework/shared/components/image_upload.dart';

class FieldConfig {
  final String name;
  final String label;
  final String? value;
  final String? Function(dynamic)? validator;
  final FieldType type;
  final Map<String, dynamic>? config;
  final Future<Map<String, String>> Function(
    String? keyword,
    int? page,
    int? perPage,
  )?
  optionsProvider;
  bool enabled;
  final bool hidden; // 新增 hidden 屬性
  final bool required; // 新增必填屬性

  FieldConfig({
    required this.name,
    required this.label,
    this.value,
    this.validator,
    this.type = FieldType.text,
    this.config,
    this.optionsProvider,
    this.enabled = true,
    this.hidden = false, // 預設不隱藏
    this.required = false, // 預設不必填
  }) : assert(
         type != FieldType.dropdown || optionsProvider != null,
         'optionsProvider must be provided for dropdown type',
       ) {
    if (type == FieldType.dropdown && optionsProvider == null) {
      throw ArgumentError('optionsProvider must be provided for dropdown type');
    }
  }

  dynamic get initialValue {
    if (type == FieldType.datePicker && value != null) {
      return DateTime.parse(value!);
    }
    return value;
  }

  // 根據輸入框類型返回對應的組件
  Widget getFormBuilderField(context, formKey) {
    // 自動加上必填驗證（若 required 為 true 且未自訂 validator）
    String? Function(dynamic)? effectiveValidator = validator;
    if (required && validator == null) {
      effectiveValidator = (value) {
        if (value == null || (value is String && value.trim().isEmpty)) {
          return '$label 為必填';
        }
        return null;
      };
    }
    // 標籤加紅色星號（只在最後加紅*，不使用 Text.rich）
    Widget labelWidget = required
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          )
        : Text(label);
    switch (type) {
      case FieldType.text:
        // 允許 config 設定 maxLines
        int maxLines = 1;
        int minLines = 1;
        if (config != null) {
          if (config!.containsKey('maxLines')) {
            final dynamic maxLinesValue = config!['maxLines'];
            if (maxLinesValue is int) {
              maxLines = maxLinesValue;
            } else if (maxLinesValue is String) {
              maxLines = int.tryParse(maxLinesValue) ?? 1;
            }
          }
          if (config!.containsKey('minLines')) {
            final dynamic minLinesValue = config!['minLines'];
            if (minLinesValue is int) {
              minLines = minLinesValue;
            } else if (minLinesValue is String) {
              minLines = int.tryParse(minLinesValue) ?? 1;
            }
          }
        }

        return FormBuilderTextField(
          name: name,
          decoration: InputDecoration(label: labelWidget),
          initialValue: initialValue,
          validator: effectiveValidator as String? Function(String?)?,
          readOnly: !enabled, // 傳遞唯讀屬性
          maxLines: maxLines,
          minLines: minLines == 1 ? 1 : null,
        );
      case FieldType.datePicker:
        return FormBuilderDateTimePicker(
          name: name,
          decoration: InputDecoration(label: labelWidget),
          initialValue: initialValue,
          validator: effectiveValidator as String? Function(DateTime?)?,
          enabled: enabled, // 使用 enabled 控制唯讀
        );
      case FieldType.checkbox:
        return FormBuilderCheckbox(
          name: name,
          title: labelWidget,
          initialValue: value == 'true',
          validator: effectiveValidator as String? Function(bool?)?,
          enabled: enabled, // 使用 enabled 控制唯讀
        );
      case FieldType.radio:
        final options = optionsProvider?.call(null, 1, 20) ?? Future.value({});
        return FutureBuilder<Map<String, String>>(
          future: options,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final optionsData = snapshot.data ?? {};
            return FormBuilderRadioGroup(
              name: name,
              decoration: InputDecoration(label: labelWidget),
              initialValue: value,
              options:
                  optionsData.entries
                      .map(
                        (entry) => FormBuilderFieldOption(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
              validator: effectiveValidator,
              enabled: enabled, // 使用 enabled 控制唯讀
            );
          },
        );
      case FieldType.dropdown:
        final options = optionsProvider?.call(null, 1, 20) ?? Future.value({});
        return FutureBuilder<Map<String, String>>(
          future: options,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final optionsData = snapshot.data ?? {};
            return FormBuilderDropdown(
              name: name,
              decoration: InputDecoration(label: labelWidget),
              initialValue: value,
              dropdownColor: Colors.grey[200],
              items:
                  optionsData.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
              validator: effectiveValidator,
              enabled: enabled, // 使用 enabled 控制唯讀
            );
          },
        );
      case FieldType.choiceChips:
        final options = optionsProvider?.call(null, 1, 20) ?? Future.value({});
        return FutureBuilder<Map<String, String>>(
          future: options,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final optionsData = snapshot.data ?? {};
            return FormBuilderChoiceChips(
              name: name,
              decoration: InputDecoration(label: labelWidget),
              initialValue: value,
              options:
                  optionsData.entries
                      .map(
                        (entry) => FormBuilderChipOption(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
              validator: effectiveValidator,
              enabled: enabled, // 使用 enabled 控制唯讀
            );
          },
        );
      case FieldType.switchField:
        return FormBuilderSwitch(
          name: name,
          title: labelWidget,
          initialValue: value == 'true',
          validator: effectiveValidator as String? Function(bool?)?,
          enabled: enabled, // 使用 enabled 控制唯讀
        );
      case FieldType.textArea:
        return FormBuilderTextField(
          name: name,
          decoration: InputDecoration(label: labelWidget),
          initialValue: value,
          maxLines: 5,
          validator: effectiveValidator as String? Function(String?)?,
          readOnly: !enabled, // 傳遞唯讀屬性
        );
      case FieldType.searchableDropdown:
        return SearchableDropdownField(
          name: name,
          label: required ? '$label *' : label, // searchableDropdown 若需紅星，於 label 結尾加 *
          initialValue: initialValue?.toString(),
          optionsProvider: optionsProvider, // 傳遞更新後的 optionsProvider
          formKey: formKey,
          validator: effectiveValidator as String? Function(String?)?,
          enabled: enabled, // 使用 enabled 控制唯讀
        );
      case FieldType.fileUpload:
        // 讓 fileUpload 也能被 FormBuilder 驗證與管理
        return FormBuilderField<String>(
          name: name,
          validator: effectiveValidator as String? Function(String?)?,
          enabled: enabled,
          initialValue: value,
          builder:
              (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FileUpload(
                    label: required ? '$label *' : label, // fileUpload 若需紅星，於 label 結尾加 *
                    enabled: enabled,
                    onFileSelected: (file) {
                      // 將檔案路徑存入表單欄位
                      field.didChange(file.path);
                    },
                  ),
                  if (field.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        field.errorText ?? '',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
        );
      case FieldType.imageUpload:
        // 整合 image_upload 元件
        return FormBuilderField<String>(
          name: name,
          validator: effectiveValidator as String? Function(String?)?,
          enabled: enabled,
          initialValue: value,
          builder:
              (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImageUpload(
                    label: required ? '$label *' : label, // imageUpload 若需紅星，於 label 結尾加 *
                    enabled: enabled,
                    onImageSelected: (file) {
                      field.didChange(file.path);
                    },
                  ),
                  if (field.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        field.errorText ?? '',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
        );
      default:
        throw UnimplementedError('FieldType not supported: $type');
    }
  }
}

enum FieldType {
  text,
  datePicker,
  timePicker,
  dropdown,
  checkbox,
  radio,
  switchField,
  textArea,
  choiceChips,
  searchableDropdown,
  fileUpload,
  imageUpload,
}
