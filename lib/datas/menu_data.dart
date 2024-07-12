import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import thư viện intl
import '../datas/auth_service.dart';

// const String domain = "http://localhost:3333";
const String domain = "https://quannhauserver.xyz";

class Category {
  final String categoryId;
  final String categoryName;
  final List<Product> products;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.products,
  });

  factory Category.fromJson(Map<String, dynamic> json, List<Product> products) {
    return Category(
      categoryId: json['categoryId'] ?? '',
      categoryName: json['cateName'] ?? '',
      products: products,
    );
  }
}

class Product {
  final String productId;
  final String productName;
  final double price;
  String imageUrl;
  final bool status;
  late final String formattedPrice;

  Product({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.status,
  }) {
    // Định dạng giá khi tạo đối tượng Product
    formattedPrice =
        NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
            .format(price);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    String defaultImageUrl = 'lib/images/default_image.png';
    return Product(
      productId: json['id'] ?? '',
      productName: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? defaultImageUrl,
      status: json['status'] == 'available',
    );
  }
}

class Menu {
  //http://localhost:3333
  //https://quannhauserver.xyz
  final String baseUrl = "$domain/api/products?page_index=1&page_size=1000";

  Future<void> createOrderDetail(String orderId, String waiterId,
      List<String> productIds, List<int> quantities, List<String> notes) async {
    try {
      String? token = await AuthService.getToken();
      if (token == null) {
        token = await AuthService.refreshToken();
        if (token == null || token.isEmpty || token == "Refresh failed") {
          throw Exception("Error when create order detail");
        }
      }

      // // Kết hợp các danh sách thành danh sách các bản ghi
      List<Map<String, dynamic>> combinedList = [];
      for (int i = 0; i < productIds.length; i++) {
        combinedList.add({
          'productId': productIds[i],
          'quantity': quantities[i],
          'note': notes[i],
        });
      }

      // // Chuyển đổi danh sách kết hợp thành Set để loại bỏ trùng lặp
      Set<Map<String, dynamic>> uniqueSet = Set.from(combinedList);

      // Chuyển lại Set thành danh sách không trùng lặp
      List<Map<String, dynamic>> uniqueList = uniqueSet.toList();

      // Tạo orderDetails từ danh sách không trùng lặp
      List<Map<String, dynamic>> orderDetails = [];
      for (var item in uniqueList) {
        orderDetails.add({
          'waiterId': waiterId,
          'productId': item['productId'],
          'quantity': item['quantity'],
          'note': item['note'],
        });
      }

      final response = await http.post(
        Uri.parse('$domain/api/orders/$orderId/order-details/'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(orderDetails),
      );

      if (response.statusCode == 200) {
        dynamic jsonResponse = jsonDecode(response.body);
        int statusC = jsonResponse['status'];

        if (statusC != 201) {
          throw Exception('Create order failed!!!');
        }
      } else {
        throw Exception('Create order failed');
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<List<Category>> fetchMenu() async {
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
        dynamic jsonResponse = jsonDecode(response.body);

        if (jsonResponse == null || jsonResponse['data'] == null) {
          throw Exception('Response or data is null');
        }

        List<dynamic> data = jsonResponse['data'];
        Map<String, List<Product>> categoryMap = {};

        data.forEach((jsonProduct) {
          if (jsonProduct['deleted'] == false) {
            Product product = Product.fromJson(jsonProduct);
            String categoryId = jsonProduct['categoryId'];
            String categoryName = jsonProduct['cateName'];

            if (!categoryMap.containsKey(categoryId)) {
              categoryMap[categoryId] = [];
            }
            if (product.status) {
              categoryMap[categoryId]!.add(product);
            }
          }
        });

        List<Category> categories = categoryMap.entries.map((entry) {
          return Category(
            categoryId: entry.key,
            categoryName: data.firstWhere(
                (element) => element['categoryId'] == entry.key)['cateName'],
            products: entry.value,
          );
        }).toList();

        return categories;
      } else {
        throw Exception('Failed to load menu');
      }
    } catch (e) {
      throw Exception('Error fetching menu: $e');
    }
  }
}
