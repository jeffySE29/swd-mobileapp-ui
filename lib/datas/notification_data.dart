import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationItem {
  final String tableName;
  final String productName;
  final int quantity;
  final String status;
  final DateTime timestamp; // Thêm trường timestamp

  NotificationItem({
    required this.tableName,
    required this.productName,
    required this.quantity,
    required this.status,
    required this.timestamp, // Khởi tạo timestamp
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      tableName: json['tableName'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      status: json['status'] ?? '',
      timestamp: DateTime.parse(json['timestamp']), // Parse timestamp từ JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableName': tableName,
      'productName': productName,
      'quantity': quantity,
      'status': status,
      'timestamp': timestamp
          .toIso8601String(), // Chuyển đổi timestamp sang chuỗi ISO 8601
    };
  }
}
