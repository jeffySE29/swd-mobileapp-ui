import 'package:flutter/material.dart';
import '../datas/table_list.dart';
import 'package:another_flushbar/flushbar.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController _phoneController = TextEditingController();
  int _amountPeople = 1;

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
      if (_selectedTable != null &&
          _selectedArea != null &&
          _amountPeople > 0) {
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
                      : Colors.teal[100], // Default color
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _areas[index].name,
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
                          ? Colors.teal[100] // Available color
                          : Colors.yellow[100], // Not available color
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _tables[index].code, // Displaying code on the table button
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
                const SizedBox(width: 5),
                Text(
                  _amountPeople.toString(),
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(width: 5),
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
    bool _isButtonEnabled = _selectedTable != null && _selectedArea != null;

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
              'Table: ${_selectedTable != null ? _tables[_selectedTable! - 1].code : "None"}',
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
                  backgroundColor: WidgetStateProperty.all<Color>(
                      Colors.teal[100]!), // Màu nền
                  foregroundColor:
                      WidgetStateProperty.all<Color>(Colors.black), // Màu chữ
                  overlayColor: WidgetStateProperty.all<Color>(Colors.blue[100]!
                      .withOpacity(0.1)), // Màu hiệu ứng khi nhấn
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
//tạm thời xong phần get
//còn phần create order là call api nữa chưa xong.