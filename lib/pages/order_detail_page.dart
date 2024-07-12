import 'package:flutter/material.dart';
import 'package:swd_group_project/pages/home_page.dart';
import 'package:swd_group_project/pages/order_page.dart';
import '../datas/order_detail_data.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:intl/intl.dart';
import '../datas/user_data.dart';
import 'menu_page.dart';

class OrderDetailPage extends StatefulWidget {
  final User user;
  final String areaName;
  final String tableId;
  final String tableName;
  final String orderId;
  final int pageIndex;

  const OrderDetailPage({
    super.key,
    required this.pageIndex,
    required this.areaName,
    required this.tableId,
    required this.tableName,
    required this.orderId,
    required this.user,
  });

  @override
  // ignore: library_private_types_in_public_api
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Map<int, int> quantities = {};
  late List<OrderDetail> orderDetails;
  List<OrderDetail> orderDetailsUI = [];
  bool isLoading = true;
  String errorMessage = '';
  double currentTotal = 0.0;
  bool check = false;
  bool _sortByAscending = false;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  void _sortOrderDetails(bool ascending) {
    setState(() {
      _sortByAscending = ascending;
      orderDetailsUI.sort((a, b) {
        // Directly compare createdAtFormat strings
        if (ascending) {
          return a.createdAtFormat.compareTo(b.createdAtFormat);
        } else {
          return b.createdAtFormat.compareTo(a.createdAtFormat);
        }
      });
    });
  }

  Widget _buildSortingButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_downward),
          onPressed: () {
            if (_sortByAscending) {
              _sortOrderDetails(false);
            } else {
              _sortOrderDetails(true);
            }
          },
        ),
        SizedBox(width: 5),
        IconButton(
          icon: Icon(Icons.arrow_upward),
          onPressed: () {
            if (!_sortByAscending) {
              _sortOrderDetails(true);
            } else {
              _sortOrderDetails(false);
            }
          },
        ),
      ],
    );
  }

  Future<void> _fetchOrderDetails() async {
    try {
      orderDetails = await fetchOrderDetails(widget.orderId);
      double total = 0.0;
      for (var orderDetail in orderDetails) {
        total += orderDetail.price * orderDetail.quantity;
      }
      setState(() {
        currentTotal = total;
        orderDetailsUI = List.from(orderDetails);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Error: $error';
        isLoading = false;
      });
    }
  }

  Widget _buildBillDialog(List<CurrentBill>? bills) {
    try {
      bool hasBills = bills != null && bills.isNotEmpty;
      bool servedAll = true;
      for (var item in orderDetails) {
        if (item.status != 'served') {
          servedAll = false;
          break;
        }
      }
      double? dialogHeight = hasBills ? null : 100; // Chiều cao của AlertDialog

      return AlertDialog(
        contentPadding: const EdgeInsets.all(0),
        title: Center(
          child: Text(
            '${widget.areaName} - ${widget.tableName}',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        content: SingleChildScrollView(
          child: hasBills
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DataTable(
                      columnSpacing: 8,
                      border: TableBorder.all(
                        color: Colors.grey[400]!,
                        width: 1.0,
                      ),
                      columns: const [
                        DataColumn(
                          label: SizedBox(
                            width: 75,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Name',
                                style: TextStyle(fontSize: 8),
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          numeric: true,
                          label: SizedBox(
                            width: 45,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Unit price',
                                style: TextStyle(fontSize: 8),
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 45,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Quantity',
                                style: TextStyle(fontSize: 8),
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          numeric: true,
                          label: SizedBox(
                            width: 60,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Total amount',
                                style: TextStyle(fontSize: 8),
                              ),
                            ),
                          ),
                        ),
                      ],
                      rows: bills!
                          .map(
                            (bill) => DataRow(cells: [
                              DataCell(Container(
                                width: 75,
                                height: 10, // Giảm chiều cao của ô
                                padding: EdgeInsets.zero,
                                margin: EdgeInsets.zero,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    bill.productName,
                                    style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )),
                              DataCell(Container(
                                width: 45,
                                height: 10, // Giảm chiều cao của ô
                                padding: EdgeInsets.zero,
                                margin: EdgeInsets.zero,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    bill.formattedBillPrice,
                                    style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )),
                              DataCell(Container(
                                width: 45,
                                height: 10, // Giảm chiều cao của ô
                                padding: EdgeInsets.zero,
                                margin: EdgeInsets.zero,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${bill.quantity}',
                                    style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )),
                              DataCell(Container(
                                width: 60,
                                height: 10, // Giảm chiều cao của ô
                                padding: EdgeInsets.zero,
                                margin: EdgeInsets.zero,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    bill.formattedTotalPrice,
                                    style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )),
                            ]),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const SizedBox(width: 50),
                          const Text(
                            'Total bill: ',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(currentTotal)} VND',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                )
              : Container(
                  height: dialogHeight,
                  child: const Center(
                    child: Text(
                      'No orders yet',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                ),
        ),
        actions: hasBills && servedAll
            ? [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await checkBill(widget.orderId);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailPage(
                            pageIndex: 3,
                            areaName: widget.areaName,
                            tableId: widget.tableId,
                            tableName: widget.tableName,
                            orderId: widget.orderId,
                            user: widget.user,
                          ),
                        ),
                      );
                    } catch (e) {
                      Flushbar(
                        message: "Error when checking bill: $e",
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      ).show(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        Colors.green[800], // Màu nền của nút "Confirm"
                  ),
                  child: const Text('Confirm'),
                ),
              ]
            : [
                ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor:
                        Colors.grey[400], // Màu nền của nút "Confirm"
                  ),
                  child: const Text('Confirm'),
                ),
              ], // Vô hiệu hóa nút Confirm khi bills rỗng hoặc không có bills nào đã được phục vụ
      );
    } catch (e) {
      Flushbar(
        message: "Error in building bill dialog: $e",
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ).show(context);
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            "Order Details",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : orderDetailsUI.isEmpty
                  ? Column(children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, top: 16.0, bottom: 5.0),
                          child: Text(
                            '${widget.areaName} - ${widget.tableName}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, top: 5, bottom: 5.0),
                          child: Text(
                            'Total ${orderDetailsUI.length} items',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, top: 5, bottom: 5),
                          child: Text(
                            'Current bill ${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(currentTotal)} VND',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 300,
                      ),
                      const Center(
                        child: Text(
                          "Nothing yet, click Order now!",
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ])
                  : Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, top: 16.0, bottom: 5.0),
                            child: Text(
                              '${widget.areaName} - ${widget.tableName}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, top: 5, bottom: 5.0),
                            child: Text(
                              'Total ${orderDetailsUI.length} items',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, top: 5, bottom: 5),
                            child: Text(
                              'Current bill ${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(currentTotal)} VND',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        _buildSortingButtons(),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: orderDetailsUI.length,
                            itemBuilder: (context, index) {
                              OrderDetail orderDetail = orderDetailsUI[index];
                              quantities[index] ??= orderDetail.quantity;
                              if (orderDetail.deleted) {
                                return const SizedBox.shrink();
                              }
                              return Card(
                                color: Colors.grey[200], // Màu nền của card
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              orderDetail.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 4.0),
                                            decoration: BoxDecoration(
                                              color: getStatusColor(
                                                  orderDetail.status),
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 0.5),
                                            ),
                                            child: Text(
                                              orderDetail.status,
                                              style: TextStyle(
                                                color: getStatusTextColor(
                                                    orderDetail.status),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            color: Colors
                                                .white, // Đặt màu nền là trắng
                                            child: Image.network(
                                              orderDetail.imageUrl,
                                              width: 200 / 3,
                                              height: 200 / 3,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Text('Note: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                    const SizedBox(width: 2),
                                                    Expanded(
                                                      child: Text(
                                                        orderDetail.note,
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            color:
                                                                Colors.black),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Text('Price: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                    const SizedBox(width: 2),
                                                    Expanded(
                                                      child: Text(
                                                          '${orderDetail.formattedPrice} VND',
                                                          style: const TextStyle(
                                                              fontSize: 11,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              color: Colors
                                                                  .black)),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Text('Order time: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                    const SizedBox(width: 2),
                                                    Expanded(
                                                      child: Text(
                                                          orderDetail
                                                              .createdAtFormat,
                                                          style: const TextStyle(
                                                              fontSize: 11,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              color: Colors
                                                                  .black)),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Container(
                                                  height:
                                                      36.0, // Đặt chiều cao cố định cho Container
                                                  child: Row(
                                                    children: [
                                                      const Text(
                                                        'Quantity: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
                                                      if (orderDetail.status ==
                                                          'pending') ...[
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons
                                                                .remove_circle_outline,
                                                            color: Colors.black,
                                                            size: 24.0,
                                                          ),
                                                          onPressed: () =>
                                                              _decreaseQuantity(
                                                                  index),
                                                          constraints:
                                                              const BoxConstraints(
                                                            minWidth: 36,
                                                            minHeight: 36,
                                                          ),
                                                          padding:
                                                              EdgeInsets.zero,
                                                          splashRadius: 20,
                                                          iconSize: 24.0,
                                                        ),
                                                        const SizedBox(
                                                            width: 2.0),
                                                        Text(
                                                          '${quantities[index]}',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        const SizedBox(
                                                            width: 2.0),
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons
                                                                .add_circle_outline,
                                                            color: Colors.black,
                                                            size: 24.0,
                                                          ),
                                                          onPressed: () =>
                                                              _increaseQuantity(
                                                                  index),
                                                          constraints:
                                                              const BoxConstraints(
                                                            minWidth: 36,
                                                            minHeight: 36,
                                                          ),
                                                          padding:
                                                              EdgeInsets.zero,
                                                          splashRadius: 20,
                                                          iconSize: 24.0,
                                                        ),
                                                      ] else ...[
                                                        const SizedBox(
                                                            width: 2),
                                                        Text(
                                                          '${quantities[index]}',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        const SizedBox(
                                                            width: 2.0),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              onPressed: () {
                // if (_listEquals(orderDetails, orderDetailsUI) == false &&
                //     check == false) {
                //   setState(() {
                //     check = true;
                //   });
                //   Flushbar(
                //     message: "Save your change before leave!",
                //     backgroundColor: Colors.green,
                //     duration: const Duration(seconds: 3),
                //   ).show(context);
                // } else {
                if (widget.pageIndex == 0 || widget.pageIndex == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                              user: widget.user,
                              initialTabIndex: widget.pageIndex,
                            )), // Thay thế PageMenu bằng trang cần quay lại
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                              user: widget.user,
                              initialTabIndex: 0,
                            )), // Thay thế PageMenu bằng trang cần quay lại
                  );
                }
                // }
              },
              backgroundColor: Colors.green[800],
              child: const Icon(
                Icons.home,
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      List<CurrentBill> bills =
                          await CurrentBill.fetchBill(widget.orderId);
                      showDialog(
                        context: context,
                        builder: (context) => _buildBillDialog(bills),
                      );
                    } catch (e) {
                      print('Error fetching bill: $e');
                      // Xử lý hiển thị thông báo lỗi nếu cần
                      Flushbar(
                        message: "Error fetching bill: $e",
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      ).show(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey[400], // Màu nền của nút "Bill"
                  ),
                  child: const Text('Bill'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuPage(
                          user: widget.user,
                          areaName: widget.areaName,
                          tableId: widget.tableId,
                          tableName: widget.tableName,
                          orderId: widget.orderId,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.amber[300], // Màu nền của edit dish
                  ),
                  child: const Text('Order'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    bool isChanged = !_listEquals(orderDetails, orderDetailsUI);

                    if (isChanged) {
                      // Xử lý lưu dữ liệu ở đây
                      await updateOrder(widget.orderId, orderDetailsUI);
                      ////
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailPage(
                            pageIndex: 3,
                            user: widget.user,
                            areaName: widget.areaName,
                            tableId: widget.tableId,
                            tableName: widget.tableName,
                            orderId: widget.orderId,
                          ),
                        ),
                      );
                    } else {
                      Flushbar(
                        message: "Nothing change",
                        backgroundColor:
                            const Color.fromARGB(255, 112, 217, 119),
                        duration: const Duration(seconds: 2),
                      ).show(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green[800], // Màu nền của save
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.grey[400]!;
      case 'cooking':
        return Colors.green[200]!;
      case 'served':
      case 'check':
      case 'finish':
        return Colors.amber[400]!; // Đậm hơn màu amber ban đầu
      default:
        return Colors.red;
    }
  }

  Color getStatusTextColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.black;
      case 'cooking':
        return Colors.black;
      case 'served':
      case 'check':
      case 'finish':
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (quantities[index]! > 1) {
        quantities[index] = quantities[index]! - 1;
        orderDetailsUI[index].quantity = quantities[index]!;
      } else {
        _showRemoveConfirmationDialog(index);
      }
    });
  }

  void _increaseQuantity(int index) {
    setState(() {
      quantities[index] = quantities[index]! + 1;
      orderDetailsUI[index].quantity = quantities[index]!;
    });
  }

  void _showRemoveConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Do you want to remove this item?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                await deleteOrderDetail(
                    widget.orderId, orderDetailsUI[index].id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailPage(
                      pageIndex: 3,
                      user: widget.user,
                      areaName: widget.areaName,
                      tableId: widget.tableId,
                      tableName: widget.tableName,
                      orderId: widget.orderId,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  bool _listEquals(List<OrderDetail> list1, List<OrderDetail> list2) {
    if (list1.length != list2.length) {
      return false;
    }

    for (int i = 0; i < list1.length; i++) {
      bool found = false;
      for (int y = 0; y < list2.length; y++) {
        if (list1[i].id == list2[y].id) {
          found = true;
          break;
        }
      }
      if (!found) {
        return true;
      }
    }

    return false;
  }
}
