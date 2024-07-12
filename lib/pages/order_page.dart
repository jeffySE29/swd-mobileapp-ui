import 'package:flutter/material.dart';
import '../datas/table_list.dart';
import 'package:another_flushbar/flushbar.dart';
import 'order_detail_page.dart';
import '../datas/user_data.dart';

class OrderPage extends StatefulWidget {
  final User user;
  const OrderPage({super.key, required this.user});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String? _selectedTable;
  String? _selectedArea;
  List<AreaModel> _areas = [];
  List<TableModel> _tables = [];
  String? note;

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

  void navigateToOrderDetailPage(
      String areaName, String tableId, String tableName, String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailPage(
          pageIndex: 0,
          user: widget.user,
          areaName: areaName,
          tableId: tableId,
          tableName: tableName,
          orderId: orderId,
        ),
      ),
    );
  }

  void _createOrder() async {
    try {
      AreaTable areaTable = AreaTable();
      String curTableName = _selectedTable != null
          ? _tables
              .firstWhere((table) => table.id.toString() == _selectedTable)
              .name
          : "";

      if (_selectedTable != null && curTableName != null) {
        String newOrderId = "";
        try {
          newOrderId = await areaTable.createOrder(_selectedTable, note);
        } catch (e) {
          // Bắt lỗi cụ thể từ createOrder và ném lại để khối try-catch chính có thể xử lý
          throw Exception("Create order error: $e");
        }

        if (newOrderId != null && newOrderId != "") {
          // Nếu thành công, hiển thị Flushbar thành công và chuyển đến OrderDetailPage
          Flushbar(
            message: "Order created successfully!",
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ).show(context);

          // Xóa hết các trang cũ và thêm OrderDetailPage mới
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(
                pageIndex: 0,
                user: widget.user,
                areaName: _selectedArea!,
                tableId: _selectedTable!,
                tableName: curTableName,
                orderId: newOrderId,
              ),
            ), // Xóa hết các trang còn lại
          );
        } else {
          throw Exception("Current table doesn't have any orders");
        }
      } else {
        // Nếu không chọn bàn, hiển thị Flushbar lỗi
        Flushbar(
          message: "Pick a table to order!",
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ).show(context);
      }
    } catch (e) {
      // Nếu xảy ra lỗi, hiển thị Flushbar lỗi
      Flushbar(
        message: "Order page: $e",
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ).show(context);
    }
  }

  Widget _buildAreaSection() {
    int availableAreaCount =
        _areas.where((area) => area.status == 'available').length;
    int totalAreaCount = _areas.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
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
            final area = _areas[index];
            return GestureDetector(
              onTap: area.status == 'available'
                  ? () => _onAreaSelected(area.name)
                  : null,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: area.status == 'available'
                      ? (_selectedArea == area.name
                          ? Colors.grey[300]
                          : Colors.teal[300])
                      : Colors.purple[100],
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      area.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black),
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
              color: Colors.black,
            ),
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
            final table = _tables[index];
            return GestureDetector(
              onTap: table.status == 'available' || table.status == 'occupied'
                  ? () async {
                      if (table.status == 'occupied') {
                        AreaTable areaTable = AreaTable();
                        String orderId =
                            await areaTable.fetchCurrentOrderAtTable(table.id);
                        navigateToOrderDetailPage(
                          _selectedArea!,
                          table.id.toString(),
                          table.name,
                          orderId,
                        );
                      } else {
                        setState(() {
                          _selectedTable = table.id.toString();
                        });
                      }
                    }
                  : null,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: table.status == 'available'
                      ? (_selectedTable == table.id.toString()
                          ? Colors.grey[300]
                          : Colors.teal[300])
                      : table.status == 'occupied'
                          ? Colors.amber[300]
                          : Colors.purple[100],
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      table.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black),
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

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5.0),
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              color: Colors.grey[300],
            ),
            const SizedBox(width: 8),
            const Text('Selected area/table on order process'),
          ],
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              color: Colors.teal[300],
            ),
            const SizedBox(width: 8),
            const Text('Available area/table to select'),
          ],
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              color: Colors.purple[100],
            ),
            const SizedBox(width: 8),
            const Text('Fixing area/table unavailable to select'),
          ],
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              color: Colors.amber[300],
            ),
            const SizedBox(width: 8),
            const Text('Occupied table select to view details'),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled = _selectedTable != null && _selectedArea != null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.green[800],
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAreaSection(),
                  const SizedBox(height: 16.0),
                  _buildTableSection(),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegend(), // Added legend for table status colors
                  const SizedBox(height: 8.0),
                  const Divider(),
                  const SizedBox(height: 8.0),
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
                      const SizedBox(width: 30),
                      const Text(
                        'Note:',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 150,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              note = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Type your note',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              overflow: TextOverflow.ellipsis,
                            ),
                            border: InputBorder.none, // Ẩn đường gạch chân
                          ),
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),
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
                            ? _tables
                                .firstWhere((table) =>
                                    table.id.toString() == _selectedTable)
                                .name
                            : "None",
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Align(
                    alignment: Alignment.center,
                    child: FractionallySizedBox(
                      widthFactor: 1.0, // 100% of the screen width
                      child: ElevatedButton(
                        onPressed: _createOrder,
                        style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all<Size>(
                            const Size(double.infinity, 50),
                          ),
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.green[800]!),
                          foregroundColor:
                              WidgetStateProperty.all<Color>(Colors.white),
                          overlayColor: WidgetStateProperty.all<Color>(
                              Colors.blue[100]!.withOpacity(0.1)),
                        ),
                        child: const Text('Create order'),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
