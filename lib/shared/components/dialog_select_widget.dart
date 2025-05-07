import 'package:flutter/material.dart';
import 'package:my_flutter_framework/styles/app_color.dart';

enum TitlePosition {
  top,
  left,
}

class DialogSelectWidget extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  final Function(String value) selectCallBack;
  final String? selectedValue;
  final String title;
  final Color? textColor;
  final TextStyle normalTextStyle;
  final TextStyle selectTextStyle;
  final Widget trailing;
  final Offset offset;
  final double maxHeight;
  final double maxWidth;
  final Color? bgColor;
  final bool animation;
  final int duration;
  final Widget? leading;
  final TitlePosition titlePosition;
  final String searchHintText;

  const DialogSelectWidget({
    super.key,
    required this.dataList,
    required this.selectCallBack,
    this.leading,
    this.selectedValue,
    this.trailing = const Icon(
      Icons.keyboard_arrow_down,
      color: AppColor.textGrey_0xFF6B6C71,
    ),
    this.textColor = AppColor.textGrey_0xFF6B6C71,
    this.offset = const Offset(0, 30),
    this.normalTextStyle = const TextStyle(
      color: AppColor.textGrey_0xFF6B6C71,
      fontSize: 20,
    ),
    this.selectTextStyle = const TextStyle(
      color: AppColor.textBlue_0xFF4470B1,
      fontSize: 20,
    ),
    this.maxHeight = 250,
    this.maxWidth = 400,
    this.bgColor = AppColor.white_0xFFFFFFFF,
    this.title = 'Select an Option',
    this.animation = true,
    this.duration = 200,
    this.titlePosition = TitlePosition.left,
    this.searchHintText = 'Search...', // 預設值
  });

  @override
  State<DialogSelectWidget> createState() => _DialogSelectWidgetState();
}

class _DialogSelectWidgetState extends State<DialogSelectWidget>
    with SingleTickerProviderStateMixin {
  late String _currentValue;
  late String _selectedLabel;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.selectedValue ?? '';

    if (widget.animation) {
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.duration),
      );
      _animation = Tween(begin: 0.0, end: 0.5).animate(CurvedAnimation(
          parent: _animationController, curve: Curves.easeInOut));
    }
  }

  @override
  void didUpdateWidget(covariant DialogSelectWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 檢查 selectedValue 是否改變
    if (widget.selectedValue != oldWidget.selectedValue) {
      setState(() {
        _currentValue = widget.selectedValue ?? '';
        _initLabel(); // 更新 _selectedLabel
      });
    }
  }

  void _initLabel() {
    if (widget.dataList.isEmpty) {
      _selectedLabel = 'No Data Available';
      _currentValue = '';
    } else if (_currentValue.isNotEmpty) {
      _selectedLabel = widget.dataList
          .firstWhere((item) => item['value'] == _currentValue)['label'];
    } else {
      // _selectedLabel = widget.dataList[0]['label'];
      // _currentValue = widget.dataList[0]['value'];
      _selectedLabel = 'No Data Available';
      _currentValue = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    _initLabel();
    return Column(
      children: [
        if (widget.titlePosition == TitlePosition.top) _buildTitle(),
        _buildDialogButton(),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      _selectedLabel,
      style: TextStyle(
        color: widget.textColor,
        fontSize: 20,
      ),
    );
  }

  Widget _buildDialogButton() {
    return GestureDetector(
      onTap: () => _showDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          // 移除框線樣式
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: FittedBox(
          child: Row(
            children: [
              if (widget.leading != null) widget.leading!,
              if (widget.titlePosition == TitlePosition.left) _buildTitle(),
              if (widget.animation) _buildAnimatedTrailing(),
              if (!widget.animation) widget.trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredList = widget.dataList;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: widget.searchHintText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredList = widget.dataList
                            .where((item) => item['label']
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: filteredList.isEmpty
                    ? Center(
                        child: Text(
                          'No results found',
                          style: widget.normalTextStyle,
                        ),
                      )
                    : ListView(
                        children: filteredList.map((item) {
                          return ListTile(
                            title: Text(
                              item['label'],
                              style: item['value'] == _currentValue
                                  ? widget.selectTextStyle
                                  : widget.normalTextStyle,
                            ),
                            onTap: () {
                              setState(() {
                                _currentValue = item['value'];
                                _selectedLabel = item['label'];
                                widget.selectCallBack(_currentValue);
                              });
                              Navigator.of(context).pop();
                            },
                          );
                        }).toList(),
                      ),
              ),
            );
          },
        );
      },
    );
  }

  // 建立動畫尾部
  Widget _buildAnimatedTrailing() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * 3.14,
          child: widget.trailing,
        );
      },
    );
  }
}
