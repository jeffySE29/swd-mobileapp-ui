import 'package:flutter/material.dart';
import '../datas/table_list.dart';
import 'package:another_flushbar/flushbar.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController _phoneController = TextEditingController();

  int? _selectedTable;
  String? _selectedArea;
  List<AreaModel> _areas = [];
  List<TableModel> _tables = [];

  @override
  void initState() {
    super.initState();
    _fetchAreas();
  }

  Future<void> _fetchAreas() async {
    try {
      AreaTable areaTable = AreaTable();
      List<AreaModel> areas = await areaTable.fetchAreas();
      setState(() {
        _areas = areas;
        if (_areas.isNotEmpty) {
          _selectedArea = _areas[0].name;
          _tables = _areas[0].tables;
        }
      });
    } catch (e) {
      print('Error fetching areas: $e');
    }
  }

  void _onAreaSelected(String areaName) {
    setState(() {
      _selectedArea = areaName;
      _tables = _areas.firstWhere((area) => area.name == areaName).tables;
      _selectedTable = null;
    });
  }

  void _createOrder() async {
    try {
      if (_selectedTable != null && _selectedArea != null) {
        Flushbar(
          message: "Order created successfully!",
          backgroundColor: const Color.fromARGB(255, 112, 217, 119),
          duration: const Duration(seconds: 3),
        ).show(context);
      } else {
        Flushbar(
          message: "Missing field!",
          backgroundColor: const Color.fromARGB(255, 241, 45, 31),
          duration: const Duration(seconds: 3),
        ).show(context);
      }
    } catch (e) {
      Flushbar(
        message: "Error when creating order: $e",
        backgroundColor: const Color.fromARGB(255, 241, 45, 31),
        duration: const Duration(seconds: 3),
      ).show(context);
    }
  }

  Widget _buildAreaSection() {
    int availableAreaCount = _areas
        .where(
            (area) => area.tables.any((table) => table.status == 'available'))
        .length;
    int totalAreaCount = _areas.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black),
            children: [
              const TextSpan(text: 'Area - '),
              TextSpan(
                text:
                    '$availableAreaCount available area / $totalAreaCount Total',
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 120,
            mainAxisExtent: 60,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _areas.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                _onAreaSelected(_areas[index].name);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: _selectedArea == _areas[index].name
                      ? Colors.grey[300] // Selected color
                      : Colors.teal[300], // Default color
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _areas[index].name,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTableSection() {
    int availableCount =
        _tables.where((table) => table.status == 'available').length;
    int totalCount = _tables.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16.0),
        RichText(
          text: TextSpan(
            style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black),
            children: [
              const TextSpan(text: 'Table - '),
              TextSpan(
                text: '$availableCount available table / $totalCount Total',
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 120,
            mainAxisExtent: 60,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _tables.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                if (_tables[index].status == 'available') {
                  setState(() {
                    _selectedTable = index + 1; // Index + 1 for table number
                  });
                }
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: _selectedTable == index + 1
                      ? Colors.grey[300] // Selected color
                      : _tables[index].status == 'available'
                          ? Colors.teal[300] // Available color
                          : Colors.amber[200], // Not available color
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _tables[index].name,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
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
    bool isButtonEnabled = _selectedTable != null && _selectedArea != null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFaa4b6b),
                Color(0xFF6b6b83),
                Color(0xFF3b8d99),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Center(
          child: Text(
            "Order",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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
            const Divider(),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Text(
                  'Area:',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedArea ?? "None",
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Text(
                  'Table:',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedTable != null
                      ? _tables[_selectedTable! - 1].name
                      : "None",
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            const SizedBox(height: 60.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isButtonEnabled ? _createOrder : null,
                  style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all<Size>(
                      const Size(250, 50),
                    ), // Set the minimum width and height of the button
                    backgroundColor: WidgetStateProperty.all<Color>(
                        Colors.teal[300]!), // Màu nền
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.black), // Màu chữ
                    overlayColor: WidgetStateProperty.all<Color>(Colors
                        .blue[100]!
                        .withOpacity(0.1)), // Màu hiệu ứng khi nhấn
                  ),
                  child: const Text(
                    'Create order',
                    style: TextStyle(
                      fontSize: 15.0, // Increase font size
                      fontWeight: FontWeight.bold, // Make text bold
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
