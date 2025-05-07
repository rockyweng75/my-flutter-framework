import 'package:flutter/material.dart';

class SearchableDropdownModal extends StatefulWidget {
  /// 提供選項的函數，返回一個 Map<String, String>，其中 key 是選項的值，value 是顯示的文本。
  /// 此函數接受一個關鍵字和頁碼，並返回對應的選項。
  final Future<Map<String, String>> Function(String? keyword, int? page, int? perPage)? optionsProvider; 

  final void Function(Map<String, String>)? onOptionsUpdated; // 新增回調參數

  const SearchableDropdownModal({super.key, this.optionsProvider, this.onOptionsUpdated});

  @override
  _SearchableDropdownModalState createState() => _SearchableDropdownModalState();
}

class _SearchableDropdownModalState extends State<SearchableDropdownModal> {
  late List<MapEntry<String, String>> options = []; // 初始化為空列表
  String searchKeyword = '';
  int currentPage = 1; // 新增頁次參數

  @override
  void initState() {
    super.initState();
    if (widget.optionsProvider != null) {
      _fetchOptions(''); // 初始化時加載默認選項
    }
  }

  void _fetchOptions(String keyword) async {
    if (widget.optionsProvider != null) {
      final fetchedOptions = await widget.optionsProvider!(keyword, 1, 20); // 更新為支持分頁
      setState(() {
        options = fetchedOptions.entries.toList();
        currentPage = 1; // 初始化頁次
      });
      if (widget.onOptionsUpdated != null) {
        widget.onOptionsUpdated!(fetchedOptions); // 回調更新選項
      }
    }
  }

  void _fetchMoreOptions(String keyword) async {
    if (widget.optionsProvider != null) {
      final fetchedOptions = await widget.optionsProvider!(keyword, currentPage + 1, 20); // 更新為支持分頁
      setState(() {
        options.addAll(fetchedOptions.entries);
        currentPage++; // 增加頁次
      });
      if (widget.onOptionsUpdated != null) {
        widget.onOptionsUpdated!(fetchedOptions); // 回調更新選項
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOptions = options
        .where((entry) => entry.value.toLowerCase().contains(searchKeyword.toLowerCase()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                searchKeyword = value;
              });
              _fetchOptions(value); // 更新選項
            },
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                _fetchMoreOptions(searchKeyword); // 滾動到底部時加載更多選項
              }
              return false;
            },
            child: ListView.builder(
              itemCount: filteredOptions.length,
              itemBuilder: (context, index) {
                final entry = filteredOptions[index];
                return ListTile(
                  title: Text(entry.value),
                  onTap: () {
                    Navigator.pop(context, {
                      'value': entry.key,
                      'label': entry.value,
                    });
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}