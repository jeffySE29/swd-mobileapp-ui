import 'dart:convert';
import 'package:http/http.dart' as http;
import '../datas/auth_service.dart';

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

  Product({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.status,
  });

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
  final String baseUrl =
      "https://quannhauserver.xyz/api/products?page_index=1&page_size=1000";

  Future<List<Category>> fetchMenu() async {
    try {
      String? token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Token is null');
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
