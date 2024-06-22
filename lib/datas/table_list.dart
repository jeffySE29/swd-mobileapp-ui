import 'package:flutter/material.dart';

class TableListPage extends StatefulWidget {
  final ValueChanged<int> onSelected;

  const TableListPage({super.key, required this.onSelected});

  @override
  _TableListState createState() => _TableListState();
}

class _TableListState extends State<TableListPage> {
  // Dữ liệu key-value
  final Map<int, String> _keyValuePairs = {
    1: 'Giá trị 1',
    2: 'Giá trị 2',
    3: 'Giá trị 3',
    4: 'Giá trị 4',
  };

  late int _selectedKey;

  @override
  void initState() {
    super.initState();
    // Đặt giá trị mặc định
    _selectedKey = _keyValuePairs.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: _selectedKey,
      items: _keyValuePairs.entries.map((entry) {
        return DropdownMenuItem<int>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedKey = newValue!;
          widget.onSelected(_selectedKey); // Gọi callback khi giá trị thay đổi
        });
      },
    );
  }
}
