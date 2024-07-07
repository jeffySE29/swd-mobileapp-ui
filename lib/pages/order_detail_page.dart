import 'package:flutter/material.dart';
import '../datas/order_detail_data.dart';
import 'menu_page.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Map<int, int> quantities = {};
  late List<OrderDetail> orderDetails;
  List<OrderDetail> orderDetailsUI = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      orderDetails = await fetchOrderDetails(widget.orderId);
      setState(() {
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

  @override
  Widget build(BuildContext context) {
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
                  ? const Center(child: Text('Nothing yet! Order now!!!'))
                  : Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, top: 16.0, bottom: 13.0),
                            child: Text(
                              'Total ${orderDetailsUI.length} items',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
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
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
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
                                          Text(
                                            '${orderDetail.cateName} - ${orderDetail.name}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
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
                                      const SizedBox(height: 16),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.network(
                                            orderDetail.imageUrl,
                                            width: 200 / 3,
                                            height: 200 / 3,
                                            fit: BoxFit.cover,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Text('Note: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                    const SizedBox(width: 8),
                                                    Text(orderDetail.note,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black))
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Text('Price: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                        orderDetail.price
                                                            .toStringAsFixed(2),
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black))
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Text('Quantity: ',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                            '${quantities[index]}',
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black))
                                                      ],
                                                    ),
                                                    const SizedBox(width: 8),
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
                                                    ],
                                                  ],
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
                Navigator.pop(
                    context); // Quay lại trang trước đó (OrderListPage)
              },
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.home),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MenuPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.blue[100], // Màu nền của edit dish
                  ),
                  child: const Text('Edit Dish'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    bool isChanged = !_listEquals(orderDetails, orderDetailsUI);

                    if (isChanged) {
                      // Xử lý lưu dữ liệu ở đây
                      setState(() {
                        orderDetails = List<OrderDetail>.from(orderDetailsUI);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nothing change'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue[400], // Màu nền của save
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
      } else {
        _showRemoveConfirmationDialog(index);
      }
    });
  }

  void _increaseQuantity(int index) {
    setState(() {
      quantities[index] = quantities[index]! + 1;
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
              onPressed: () {
                setState(() {
                  orderDetailsUI[index].deleted = true;
                });
                Navigator.of(context).pop();
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
      if (list1[i] != list2[i]) {
        return false;
      }
    }
    return true;
  }
}
