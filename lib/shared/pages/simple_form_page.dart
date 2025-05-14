import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/shared/components/custom_button.dart';
import 'package:my_flutter_framework/shared/components/form_builder/dev_form_builder.dart';
import 'package:my_flutter_framework/shared/field_config.dart';
import 'package:my_flutter_framework/shared/models/custom_style.dart';
import 'package:my_flutter_framework/styles/app_color.dart';
import 'package:my_flutter_framework/styles/theme_data.dart';

enum ViewMode { create, edit, view }

abstract class SimpleFormPage<T extends ConsumerStatefulWidget>
    extends ConsumerStatefulWidget {
  final String title;
  final double fieldSpacing;
  final ViewMode viewMode; // 新增檢視模式屬性

  const SimpleFormPage({
    required this.title,
    this.fieldSpacing = 20.0,
    this.viewMode = ViewMode.view, // 預設為檢視模式
    super.key,
  });
}

abstract class SimpleFormPageState<T extends SimpleFormPage>
    extends ConsumerState<T> {
  late String pageTitle;
  late ViewMode viewMode; // 新增檢視模式屬性
  late bool isViewMode;
  late bool isEditMode = false; // 新增編輯模式屬性
  late bool isCreateMode = false; // 新增創建模式屬性
  late bool hasEditPermission = false; // 預設為有編輯權限
  @override
  void initState() {
    super.initState();
    pageTitle = getPageTitle();
    viewMode = widget.viewMode; // 初始化檢視模式
    isViewMode = widget.viewMode == ViewMode.view; // 初始化檢視模式
    isEditMode = widget.viewMode == ViewMode.edit; // 初始化編輯模式
    isCreateMode = widget.viewMode == ViewMode.create; // 初始化創建模式
    hasPermissionToEdit().then((hasPermission) {
      if (hasPermission) {
        if (mounted) {
          setState(() {
            hasEditPermission = hasPermission; // 如果有權限，則切換為編輯模式
          });
        }
      }
    });
  }

  void toggleViewMode() {
    if (mounted) {
      setState(() {
        isViewMode = !isViewMode; // 切換檢視模式
        isEditMode = !isViewMode; // 切換編輯模式
        viewMode = isViewMode ? ViewMode.edit : ViewMode.view; // 切換檢視模式
      });
    }
  }

  String getPageTitle();

  List<FieldConfig> getFields();

  Future<void> onSave(Map<String, dynamic> formData);

  Future<void> onDelete(Map<String, dynamic> formData);

  /// 提供權限的函數，返回bool值，表示是否有權限打開編輯頁面
  Future<bool> hasPermissionToEdit() async {
    // 在這裡實現權限檢查的邏輯
    return true; // 返回是否有權限
  }

  Widget? buildBottomAppBar(
    BuildContext context,
    GlobalKey<FormBuilderState> formKey,
  ) {
    return hasEditPermission
        ? BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: isViewMode
                  ? [
                      Flexible(
                        child: CustomButton(
                          label: 'Edit',
                          style: CustomStyle(backgroundColor: Theme.of(context).colorScheme.warning),
                          onTap: () {
                            toggleViewMode(); // 切換為編輯模式
                          },
                        ),
                      ),
                    ]
                  : [
                      if (isEditMode)
                        Flexible(
                          child: CustomButton(
                            label: 'Delete',
                            style: CustomStyle(
                              backgroundColor: Theme.of(context).colorScheme.error,
                            ),
                            onTap: () {
                              onDelete.call(
                                formKey.currentState?.value ?? {},
                              ); // 提交刪除請求
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      Flexible(
                        child: CustomButton(
                          label: 'Submit',
                          style: CustomStyle(backgroundColor: Theme.of(context).colorScheme.success),
                          onTap: () {
                            if (formKey.currentState?.saveAndValidate() ?? false) {
                              onSave.call(
                                formKey.currentState?.value ?? {},
                              ); // 提交當前表單數據
                            }
                          },
                        ),
                      ),
                    ],
            ),
          )
        : null; // 如果沒有編輯權限，則不顯示底部按鈕
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DevFormBuilder(
          testMode: dotenv.env['DEBUG_MODE'] == 'true',
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...getFields()
                  .map(
                    (field) => Padding(
                      padding: EdgeInsets.only(
                        bottom: (widget as SimpleFormPage).fieldSpacing,
                      ),
                      child: field.getFormBuilderField(context, formKey),
                    ),
                  )
                  .toList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomAppBar(context, formKey),
    );
  }
}
