import 'dart:convert';
import 'package:http/http.dart' as http;
import '../datas/auth_service.dart';

// const String domain = "http://localhost:3333";
const String domain = "https://quannhauserver.xyz";

class Order {
  final String id;
  final String code;
  final String tableId;
  final String areaName;
  final String customerId;
  final String status;
  final String tableName;
  final String customerPhone;
  final String createdAtFormat;
  Order({
    required this.id,
    required this.code,
    required this.tableId,
    required this.areaName,
    required this.customerId,
    required this.status,
    required this.tableName,
    required this.customerPhone,
    required this.createdAtFormat,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      tableId: json['tableId'] ?? '',
      areaName: json['table']?['area']?['name'] ?? '',
      customerId: json['customerId'] ?? '',
      status: json['status'] ?? '',
      tableName: json['table']?['name'] ?? '',
      customerPhone: json['customer']?['phone'] ?? '--',
      createdAtFormat: json['createdAtFormat'] ?? '',
    );
  }
}

Future<List<Order>> fetchOrders() async {
  //http://localhost:3333
  //https://quannhauserver.xyz
  const String apiUrl = '$domain/api/orders/date?page_index=1&page_size=1000';
  try {
    String? token = await AuthService.getToken();
    if (token == null) {
      String? newToken = await AuthService.refreshToken();
      if (newToken == null ||
          newToken.isEmpty ||
          newToken == "Refresh failed") {
        throw Exception("Error when fetching orders");
      } else {
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': newToken,
          },
        );
        return _processResponse(response);
      }
    } else {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': token,
        },
      );
      return _processResponse(response);
    }
  } catch (e) {
    throw Exception('Error fetching orders: $e');
  }
}

List<Order> _processResponse(http.Response response) {
  if (response.statusCode == 200) {
    var jsonData = jsonDecode(response.body);
    List<dynamic> orderData = jsonData['data'] ?? [];
    if (orderData.isEmpty) {
      // throw Exception('No data for order list');
      orderData = [];
    }
    List<Order> orders = orderData.map((json) {
      return Order.fromJson({
        ...json,
        'customerId': json['customerId'] ?? '',
      });
    }).toList();
    if (orders.length == 0) return [];

    // Lọc những order có status là "pending"
    orders = orders.where((order) => order.status == 'pending').toList();

    // Sắp xếp theo createdAtFormat mới nhất lên đầu
    orders.sort((a, b) => b.createdAtFormat.compareTo(a.createdAtFormat));

    return orders;
  } else {
    throw Exception('Failed to fetch order list');
  }
}
