import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:my_flutter_framework/shared/components/form_builder/searchable_dropdown_modal.dart';

class SearchableDropdownField extends StatefulWidget {
  final String name;
  final String label;
  final String? initialValue;
  final Future<Map<String, String>> Function(String? keyword, int? page, int? perPage)? optionsProvider; 
  final GlobalKey<FormBuilderState> formKey;
  final String? Function(String?)? validator;
  final bool enabled; // 新增唯讀屬性

  const SearchableDropdownField({
    required this.name,
    required this.label,
    required this.initialValue,
    required this.optionsProvider,
    required this.formKey,
    this.validator,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  @override
  _SearchableDropdownFieldState createState() => _SearchableDropdownFieldState();
}

class _SearchableDropdownFieldState extends State<SearchableDropdownField> {
  String? _displayedLabel;
  Map<String, String>? _options;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.optionsProvider != null) {
      widget.optionsProvider!(null, 1, 20).then((options) {
        final label = options[widget.initialValue];
        if (label != null) {
          setState(() {
            _displayedLabel = label;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField(
      name: widget.name,
      validator: widget.validator,
      initialValue: widget.initialValue,
      builder: (FormFieldState<dynamic> field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            errorText: field.errorText,
            suffixIcon: widget.enabled ? Icon(Icons.arrow_drop_down) : null,
          ),
          child: GestureDetector(
            onTap: widget.enabled
                ? () async {
                    final selectedItem = await showModalBottomSheet<Map<String, String>>(
                      context: context,
                      builder: (BuildContext context) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SearchableDropdownModal(
                            optionsProvider: widget.optionsProvider,
                            onOptionsUpdated: (updatedOptions) {
                              setState(() {
                                _options = updatedOptions;
                              });
                            },
                          ),
                        );
                      },
                    );

                    if (selectedItem != null) {
                      final selectedLabel = selectedItem['label'];
                      final selectedValue = selectedItem['value'];

                      field.didChange(selectedValue);
                      setState(() {
                        _displayedLabel = selectedLabel;
                      });
                    }
                  }
                : null, // 禁用時不執行 onTap
            child: Text(
              _displayedLabel ?? '',
              style: TextStyle(
                color: _displayedLabel == null ? Colors.grey : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}
