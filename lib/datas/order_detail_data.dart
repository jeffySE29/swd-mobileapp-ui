import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import thư viện intl
import '../datas/auth_service.dart';

// const String domain = "http://localhost:3333";
const String domain = "https://quannhauserver.xyz";

class OrderDetail {
  final String id; // orderDetailsId
  final String orderId; // order của id bằng với id nhận được từ OrderListPage
  final String waiterId; // ném userId vô đây lúc tạo orderDetail
  final String name; // productName
  final double price;
  late final String formattedPrice;
  int quantity;
  String imageUrl;
  final String cateName;
  final String note;
  final String status;
  bool deleted; // New property
  final String createdAtFormat;

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.waiterId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.cateName,
    required this.note,
    required this.status,
    this.deleted = false, // Default value false
    required this.createdAtFormat,
  }) {
    // Định dạng giá khi tạo đối tượng Product
    formattedPrice =
        NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
            .format(price / quantity);
  }

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    // Default image URL
    String defaultImageUrl = 'lib/images/default_image.png';
    // Handle imageUrl if null or empty
    String imageUrl =
        (json['product']['imageUrl'] as String?)?.isNotEmpty == true
            ? json['product']['imageUrl']
            : defaultImageUrl;

    // Handle note if null or empty
    String note =
        (json['note'] as String?)?.isNotEmpty == true ? json['note'] : '--';

    return OrderDetail(
      id: json['id'],
      orderId: json['orderId'],
      waiterId: json['waiterId'],
      name: json['product']['name'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      imageUrl: imageUrl,
      cateName: json['product']['category']['name'],
      note: note,
      status: json['status'],
      deleted: json['deleted'] ??
          false, // Assigning deleted from JSON, defaulting to false
      createdAtFormat: json['createdAtFormat'],
    );
  }
}

Future<void> updateOrder(String orderId, List<OrderDetail> orderDetails) async {
  String baseUrl = "$domain/api/orders/$orderId/order-details/for-all";
  try {
    print(orderId);

    String? token = await AuthService.getToken();
    if (token == null) {
      token = await AuthService.refreshToken();
      if (token == null || token.isEmpty || token == "Refresh failed") {
        throw Exception("Error when update order");
      }
    }

    // Chuyển đổi danh sách OrderDetail thành định dạng JSON
    List<Map<String, dynamic>> orderDetailsJson =
        orderDetails.map((orderDetail) {
      return {
        "id": orderDetail.id,
        "quantity": orderDetail.quantity,
        "note": orderDetail.note,
        "status": orderDetail.status,
      };
    }).toList();

    print(orderDetailsJson);

    final response = await http.put(
      Uri.parse(baseUrl),
      body: jsonEncode(
          orderDetailsJson), // Chuyển đổi danh sách thành JSON string
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
    );
    print(response);
    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      print(jsonBody);
      int insideStatus = jsonBody['status'];
      if (insideStatus != 200) {
        throw Exception("Error when update order!");
      }
    } else {
      throw Exception('Failed to update order');
    }
  } catch (e) {
    throw Exception("Error when update order: $e");
  }
}

Future<void> checkBill(String orderId) async {
  String baseUrl = "$domain/api/orders/$orderId/checkBill";
  try {
    String? token = await AuthService.getToken();
    if (token == null) {
      token = await AuthService.refreshToken();
      if (token == null || token.isEmpty || token == "Refresh failed") {
        throw Exception("Error when check bill");
      }
    }
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      int insideStatus = jsonBody['status'];
      if (insideStatus != 200) {
        throw Exception("Error when check bill!");
      }
    } else {
      throw Exception('Failed to load order details');
    }
  } catch (e) {
    throw Exception("Error when check bill: $e");
  }
}

Future<void> deleteOrderDetail(String orderId, String orderDetailsId) async {
  String baseUrl = "$domain/api/orders/$orderId/order-details/$orderDetailsId";
  try {
    String? token = await AuthService.getToken();
    if (token == null) {
      token = await AuthService.refreshToken();
      if (token == null || token.isEmpty || token == "Refresh failed") {
        throw Exception("Error when delete orderdetail");
      }
    }
    final response = await http.delete(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      int insideStatus = jsonBody['status'];
      if (insideStatus != 200) {
        throw Exception("Error when delete orderdetail!");
      }
    } else {
      throw Exception('Failed to load delete orderdetail');
    }
  } catch (e) {
    throw Exception("Error when delete orderdetail: $e");
  }
}

Future<List<OrderDetail>> fetchOrderDetails(String orderId) async {
  //http://localhost:3333
  //https://quannhauserver.xyz
  final String baseUrl =
      "$domain/api/orders/$orderId/order-details?page_index=1&page_size=1000";
  try {
    String? token = await AuthService.getToken();
    if (token == null) {
      token = await AuthService.refreshToken();
      if (token == null || token.isEmpty || token == "Refresh failed") {
        throw Exception("Error when fetching order details");
      }
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);

      // Log the JSON response for debugging
      if (jsonBody is Map<String, dynamic> && jsonBody.containsKey('data')) {
        final List<dynamic> data = jsonBody['data'];

        // Create a list of OrderDetail instances from JSON data
        List<OrderDetail> orderDetails = data
            .map((item) => OrderDetail.fromJson(item))
            .where((orderDetail) =>
                !orderDetail.deleted) // Filter out deleted items
            .toList();

        return orderDetails;
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to load order details');
    }
  } catch (e) {
    throw Exception("Error when fetching order details: $e");
  }
}

class CurrentBill {
  final String productId;
  final int quantity;
  final double price;
  final double totalPrice;
  final String productName;
  String formattedBillPrice;
  String formattedTotalPrice;

  CurrentBill({
    required this.productId,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.productName,
  })  : formattedBillPrice =
            NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                .format(price),
        formattedTotalPrice =
            NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                .format(totalPrice);

  factory CurrentBill.fromJson(Map<String, dynamic> json) {
    return CurrentBill(
      productId: json['productId'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      totalPrice: (json['totalAmount'] ?? 0).toDouble(),
      productName: json['product']['name'] ?? '',
    );
  }

  static Future<List<CurrentBill>> fetchBill(String orderId) async {
    //http://localhost:3333
    //https://quannhauserver.xyz
    final String baseUrl = "$domain/api/orders/$orderId/generalBill";
    try {
      String? token = await AuthService.getToken();
      if (token == null || token.isEmpty || token == "Refresh failed") {
        throw Exception("Error when fetching order details");
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        // Log the JSON response for debugging
        if (jsonBody is Map<String, dynamic> && jsonBody.containsKey('data')) {
          final List<dynamic> orderDetails = jsonBody['data']['orderDetails'];

          // Create a list of CurrentBill instances from JSON data
          List<CurrentBill> bills =
              orderDetails.map((item) => CurrentBill.fromJson(item)).toList();

          // Calculate formatted prices for each bill
          for (var bill in bills) {
            bill.formattedBillPrice = NumberFormat.currency(
                    locale: 'vi_VN', symbol: '', decimalDigits: 0)
                .format(bill.price);
            bill.formattedTotalPrice = NumberFormat.currency(
                    locale: 'vi_VN', symbol: '', decimalDigits: 0)
                .format(bill.totalPrice);
          }

          return bills;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load order details');
      }
    } catch (e) {
      throw Exception("Error when fetch bill: $e");
    }
  }
}
