import 'dart:convert';
import 'package:http/http.dart' as http;
import '../datas/auth_service.dart';

class OrderDetail {
  final String id; // orderDetailId
  final String orderId; // order của id bằng với id nhận được từ OrderListPage
  final String waiterId; // ném userId vô đây lúc tạo orderDetail
  final String name; // productName
  final double price;
  int quantity;
  String imageUrl;
  final String cateName;
  final String note;
  final String status;
  bool deleted; // New property

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
  });

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
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      imageUrl: imageUrl,
      cateName: json['product']['category']['name'],
      note: note,
      status: json['status'],
      deleted: json['deleted'] ??
          false, // Assigning deleted from JSON, defaulting to false
    );
  }
}

Future<List<OrderDetail>> fetchOrderDetails(String orderId) async {
  try {
    String? token = await AuthService.getToken();
    if (token == null) {
      String? newToken = await AuthService.refreshToken();
      if (newToken == null ||
          newToken.isEmpty ||
          newToken == "Refresh failed") {
        throw Exception("Error when fetching order details");
      } else {
        final response = await http.get(
          Uri.https('quannhauserver.xyz', '/api/orders/$orderId/order-details'),
          headers: {'Authorization': newToken},
        );
        if (response.statusCode == 200) {
          final jsonBody = jsonDecode(response.body);
          final List<dynamic> data = jsonBody['data'];

          // Create a list of OrderDetail instances from JSON data
          List<OrderDetail> orderDetails = data
              .map((item) => OrderDetail.fromJson(item))
              .where((orderDetail) =>
                  !orderDetail.deleted) // Filter out deleted items
              .toList();

          return orderDetails;
        } else {
          throw Exception('Failed to load order details');
        }
      }
    } else {
      final response = await http.get(
        Uri.https('quannhauserver.xyz', '/api/orders/$orderId/order-details'),
        headers: {'Authorization': token},
      );
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final List<dynamic> data = jsonBody['data'];

        // Create a list of OrderDetail instances from JSON data
        List<OrderDetail> orderDetails = data
            .map((item) => OrderDetail.fromJson(item))
            .where((orderDetail) =>
                !orderDetail.deleted) // Filter out deleted items
            .toList();

        return orderDetails;
      } else {
        throw Exception('Failed to load order details');
      }
    }
  } catch (e) {
    throw Exception("Error when getting order details: $e");
  }
}
