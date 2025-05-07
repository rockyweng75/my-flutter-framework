import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/shared/components/custom_button.dart';
import 'package:my_flutter_framework/shared/components/form_builder/dev_form_builder.dart';
import 'package:my_flutter_framework/shared/field_config.dart';
import 'package:my_flutter_framework/shared/models/custom_style.dart';
import 'package:my_flutter_framework/shared/order_config.dart';
import 'package:my_flutter_framework/shared/utils/json_helper.dart';
import 'package:my_flutter_framework/styles/app_color.dart';

abstract class SimpleQueryFormPage extends ConsumerStatefulWidget {
  final Widget? child; // 新增可傳入的子層
  final double fieldSpacing;
  final Function(Map<String, dynamic>)? onFormSubmit; // 新增回調函數

  const SimpleQueryFormPage({
    super.key,
    this.fieldSpacing = 20.0,
    this.child, // 接收子層
    this.onFormSubmit, // 接收回調函數
  });
}

/// 用來自訂查詢表單的頁面
abstract class SimpleQueryFormPageState<T extends SimpleQueryFormPage>
    extends ConsumerState<T> {
  late GlobalKey<FormBuilderState> formKey; // 定義表單的 key

  // 用於存儲查詢和排序表單的資料
  Map<String, dynamic> formDataStorage = {
    'search': {}, // 存儲查詢表單的資料
    'sort': {},   // 存儲排序表單的資料
  };

  List<FieldConfig> getFields();
  List<OrderConfig> getOrderFields();


  Widget getFormBuilderField(GlobalKey<FormBuilderState> formKey) {
    return DevFormBuilder(
      testMode: dotenv.env['DEBUG_MODE'] == 'true',
      key: formKey,
      initialValue: formDataStorage['search'].cast<String, dynamic>(), // 顯式轉換類型
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...getFields()
              .map(
                (field) => Padding(
                  padding: EdgeInsets.only(
                    bottom: (widget as SimpleQueryFormPage).fieldSpacing,
                  ),
                  child: field.getFormBuilderField(context, formKey),
                ),
              )
              .toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget getOrderFormBuilderField(formKey, SimpleQueryFormPageState state) {
    return DevFormBuilder(
      testMode: dotenv.env['DEBUG_MODE'] == 'true',
      initialValue: formDataStorage['sort'].cast<String, dynamic>(), // 顯式轉換類型
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 確保 order 字段存在於表單中
          FormBuilderField(
            name: 'order',
            builder: (FormFieldState<dynamic> field) {
              return const SizedBox.shrink(); // 隱藏該字段，僅用於存儲值
            },
          ),
          ...getOrderFields()
              .map(
                (field) => Padding(
                  padding: EdgeInsets.only(
                    bottom: (widget as SimpleQueryFormPage).fieldSpacing,
                  ),
                  child: field.getOrderField(context, formKey, state),
                ),
              )
              .toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Map<String, bool> buttonQueryConditions = {
    '查詢': false,
    '排序': false,
    '清除': false,
  };

  Widget _buildActionButtonWithBadge(
    String label,
    Icon icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: 100,
              child: CustomButton(
                label: label,
                type: ButtonType.icon,
                icon: icon,
                style: CustomStyle(
                  backgroundColor: AppColor.menuBackground,
                  textStyle: TextStyle(
                    color: AppColor.menuText,
                    fontSize: 16.0,
                  ),
                  border: Border.all(color: AppColor.menuBorder, width: 1.0),
                ),
                onTap: onTap,
              ),
            ),
          ),

          if (buttonQueryConditions[label] == true)
            Positioned(
              top: 5,
              right: -5,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void searchOnTap() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('查詢表單'),
          content: SingleChildScrollView(
            child: getFormBuilderField(
              formKey,
            ), // 使用 getFormBuilderField 顯示表單內容
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (formKey.currentState?.saveAndValidate() ?? false) {
                  final formData = formKey.currentState?.value; // 獲取表單資料
                  if (formData != null) {
                    formDataStorage['search'] = formData; // 存儲查詢表單資料
                  }
                  if (widget.onFormSubmit != null && formData != null) {
                    widget.onFormSubmit!(formData);
                  }
                  if (mounted) {
                    setState(() {
                      buttonQueryConditions['查詢'] = true; // 模擬有查詢條件
                    });
                  }
                  Navigator.of(context).pop();
                } else {
                  // 表單驗證失敗的處理邏輯
                  print('表單驗證失敗');
                }
              },
              child: const Text('確定'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  void sortOnTap() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('排序表單'),
          content: SingleChildScrollView(
            child: getOrderFormBuilderField(
              formKey,
              this, // 傳遞當前狀態以便於排序字段的處理
            ), // 使用 getOrderFormBuilderField 顯示表單內容
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (formKey.currentState?.saveAndValidate() ?? false) {
                  final formData = formKey.currentState?.value; // 獲取表單資料
                  if (formData != null) {
                    formDataStorage['sort'] = formData; // 存儲排序表單資料
                  }
                  if (widget.onFormSubmit != null && formData != null) {
                    widget.onFormSubmit!(formData);
                  }
                  if (mounted) {
                    setState(() {
                      buttonQueryConditions['排序'] = true; // 模擬有排序條件
                    });
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('確定'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // 清除與此 State 相關的所有引用以避免記憶體洩漏
    formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    formKey = GlobalKey<FormBuilderState>(); // 定義表單的 key
    var testMode = dotenv.env['DEBUG_MODE'] == 'true'; // 獲取測試模式的環境變數
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (testMode)
                  _buildDebugInfo(formKey), // 顯示表單資料的按鈕
                _buildActionButtonWithBadge(
                  '查詢',
                  const Icon(Icons.search),
                  searchOnTap,
                ),
                _buildActionButtonWithBadge(
                  '排序',
                  const Icon(Icons.sort),
                  sortOnTap,
                ),
                _buildActionButtonWithBadge('清除', const Icon(Icons.clear), () {
                  if (mounted) {
                    setState(() {
                      buttonQueryConditions['查詢'] = false;
                      buttonQueryConditions['排序'] = false;
                    });
                  }
                }),

                if (widget.child != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Scrollbar(
                      child: SingleChildScrollView(child: widget.child),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugInfo(GlobalKey<FormBuilderState> formKey) {
    Map<String, dynamic> fields = formDataStorage; // 獲取當前表單的所有字段

    return Container(
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
                      fields
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
    );
  }
}
