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
  final Future<Map<String, String>> Function(
    String? keyword,
    int? page,
    int? perPage,
  )?
  optionsProvider;
  bool enabled;
  final bool hidden; // 新增 hidden 屬性

  FieldConfig({
    required this.name,
    required this.label,
    this.value,
    this.validator,
    this.type = FieldType.text,
    this.optionsProvider,
    this.enabled = true,
    this.hidden = false, // 預設不隱藏
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
    switch (type) {
      case FieldType.text:
        return FormBuilderTextField(
          name: name,
          decoration: InputDecoration(labelText: label),
          initialValue: initialValue,
          validator: validator as String? Function(String?)?,
          readOnly: !enabled, // 傳遞唯讀屬性
        );
      case FieldType.datePicker:
        return FormBuilderDateTimePicker(
          name: name,
          decoration: InputDecoration(labelText: label),
          initialValue: initialValue,
          validator: validator as String? Function(DateTime?)?,
          enabled: enabled, // 使用 enabled 控制唯讀
        );
      case FieldType.checkbox:
        return FormBuilderCheckbox(
          name: name,
          title: Text(label),
          initialValue: value == 'true',
          validator: validator as String? Function(bool?)?,
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
              decoration: InputDecoration(labelText: label),
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
              validator: validator,
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
              decoration: InputDecoration(labelText: label),
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
              validator: validator,
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
              decoration: InputDecoration(labelText: label),
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
              validator: validator,
              enabled: enabled, // 使用 enabled 控制唯讀
            );
          },
        );
      case FieldType.switchField:
        return FormBuilderSwitch(
          name: name,
          title: Text(label),
          initialValue: value == 'true',
          validator: validator as String? Function(bool?)?,
          enabled: enabled, // 使用 enabled 控制唯讀
        );
      case FieldType.textArea:
        return FormBuilderTextField(
          name: name,
          decoration: InputDecoration(labelText: label),
          initialValue: value,
          maxLines: 5,
          validator: validator as String? Function(String?)?,
          readOnly: !enabled, // 傳遞唯讀屬性
        );
      case FieldType.searchableDropdown:
        return SearchableDropdownField(
          name: name,
          label: label,
          initialValue: initialValue?.toString(),
          optionsProvider: optionsProvider, // 傳遞更新後的 optionsProvider
          formKey: formKey,
          validator: validator as String? Function(String?)?,
          enabled: enabled, // 使用 enabled 控制唯讀
        );
      case FieldType.fileUpload:
        // 讓 fileUpload 也能被 FormBuilder 驗證與管理
        return FormBuilderField<String>(
          name: name,
          validator: validator as String? Function(String?)?,
          enabled: enabled,
          initialValue: value,
          builder:
              (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FileUpload(
                    label: label,
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
          validator: validator as String? Function(String?)?,
          enabled: enabled,
          initialValue: value,
          builder:
              (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImageUpload(
                    label: label,
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
