import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
// Sử dụng dữ liệu từ file table_list.dart

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isButtonEnabled = false;
  int _amountPeople = 1;

  final RegExp phoneNumberRegex = RegExp(r'^\d{10}$');

  int? _selectedTable;
  String? _selectedArea;

  List<String> areas = ['Area 1', 'Area 2', 'Area 3']; // Dữ liệu mẫu cho Area
  List<String> tables = [
    'Table 1',
    'Table 2',
    'Table 3',
    'Table 4',
    'Table 5',
    'Table 6',
    'Table 7',
    'Table 8',
    'Table 9',
    'Table 10'
  ]; // Dữ liệu mẫu cho Table

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    setState(() {
      _isButtonEnabled = _phoneController.text.isNotEmpty;
    });
  }

  void _createOrder() {
    final String phoneNumber = _phoneController.text;
    if (phoneNumber.isNotEmpty &&
        phoneNumberRegex.hasMatch(phoneNumber.trim()) &&
        _selectedTable != null &&
        _selectedArea != null) {
      Flushbar(
        message:
            "Create order success for $_selectedArea - $_selectedTable with phone number $phoneNumber and $_amountPeople people",
        backgroundColor: const Color.fromARGB(255, 112, 217, 119),
        duration: const Duration(seconds: 3),
      ).show(context);
    } else {
      Flushbar(
        message: 'Please fill all required fields correctly.',
        backgroundColor: const Color.fromARGB(255, 241, 45, 31),
        duration: const Duration(seconds: 3),
      ).show(context);
    }
  }

  Widget _buildAreaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Area',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 120,
            mainAxisExtent: 60, // Halve the height of the grid items
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: areas.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedArea = areas[index];
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: _selectedArea == areas[index]
                      ? Colors.blue[100]
                      : Colors.grey[300],
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  areas[index],
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTableSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16.0),
        const Text(
          'Table',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 120,
            mainAxisExtent: 60, // Halve the height of the grid items
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: tables.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTable = index + 1; // Index + 1 for table number
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: _selectedTable == index + 1
                      ? Colors.blue[100]
                      : Colors.grey[300],
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  tables[index],
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Amount People',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_amountPeople > 1) {
                        _amountPeople--;
                      }
                    });
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                const SizedBox(width: 5), // Add a 5px gap
                Text(
                  _amountPeople.toString(),
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(width: 5), // Add a 5px gap
                IconButton(
                  onPressed: () {
                    setState(() {
                      _amountPeople++;
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[100],
        title: const Center(
          child: Text(
            "Order page",
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAreaSection(),
            const SizedBox(height: 16.0),
            _buildTableSection(),
            const SizedBox(height: 16.0),
            _buildAmountSection(),
            const SizedBox(height: 16.0),
            const Divider(),
            const SizedBox(height: 16.0),
            Text(
              'Area: ${_selectedArea ?? "None"}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Table: ${_selectedTable != null ? "Table $_selectedTable" : "None"}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Amount: $_amountPeople people',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: _isButtonEnabled ? _createOrder : null,
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all<Size>(
                    const Size(250, 50),
                  ), // Set the minimum width and height of the button
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.teal[100]!),
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                  overlayColor: WidgetStateProperty.all<Color>(
                      Colors.blue[100]!.withOpacity(0.1)),
                ),
                child: const Text('Create order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
