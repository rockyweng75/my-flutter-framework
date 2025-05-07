import 'package:flutter/material.dart';

class SearchableDropdownModal extends StatefulWidget {
  final Future<Map<String, String>> Function(String)? optionsProvider;

  const SearchableDropdownModal({
    Key? key,
    this.optionsProvider,
  }) : super(key: key);

  @override
  _SearchableDropdownModalState createState() => _SearchableDropdownModalState();
}

class _SearchableDropdownModalState extends State<SearchableDropdownModal> {
  List<MapEntry<String, String>> options = [];
  String searchKeyword = '';

  @override
  void initState() {
    super.initState();
    if (widget.optionsProvider == null) {
      options = [];
    }
  }

  void _fetchOptions(String keyword) async {
    if (widget.optionsProvider != null) {
      final fetchedOptions = await widget.optionsProvider!(keyword);
      setState(() {
        options = fetchedOptions.entries.toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              _fetchOptions(value);
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final entry = options[index];
              return ListTile(
                title: Text(entry.value),
                onTap: () {
                  Navigator.pop(context, entry.key);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}