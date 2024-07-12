import 'dart:convert';
import 'package:http/http.dart' as http;
import '../datas/auth_service.dart';

// const String domain = "http://localhost:3333";
const String domain = "https://quannhauserver.xyz";

class TableModel {
  final String id;
  final String code;
  final String areaId;
  final String name;
  final String description;
  final String status;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  TableModel({
    required this.id,
    required this.code,
    required this.areaId,
    required this.name,
    required this.description,
    required this.status,
    required this.deleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      code: json['code'],
      areaId: json['areaId'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
      deleted: json['deleted'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class AreaModel {
  final String name;
  final String status;
  final List<TableModel> tables;

  AreaModel({
    required this.name,
    required this.status,
    required this.tables,
  });

  factory AreaModel.fromJson(String name, Map<String, dynamic> json) {
    List<TableModel> tables = (json['tables'] as List)
        .map((data) => TableModel.fromJson(data))
        .toList();
    return AreaModel(name: name, status: json['status'], tables: tables);
  }
}

class AreaTable {
  //http://localhost:3333
  //https://quannhauserver.xyz
  final String baseUrl = "$domain/api/areas/detail/";

  Future<List<AreaModel>> fetchAreas() async {
    try {
      String? token = await AuthService.getToken();
      if (token == null) {
        String? newToken = await AuthService.refreshToken();
        if (newToken == null ||
            newToken == "" ||
            newToken == "Refresh failed") {
          throw Exception("Error when fetching area table");
        } else {
          token = newToken;
        }
      }
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': token,
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body)['data'];
        List<AreaModel> areas = [];

        data.forEach((areaName, areaData) {
          areas.add(AreaModel.fromJson(areaName, areaData));
        });
        return areas;
      } else {
        throw Exception('Failed to load areas');
      }
    } catch (e) {
      throw Exception("Failed to fetch areas: $e");
    }
  }

  Future<String> fetchCurrentOrderAtTable(String tableId) async {
    try {
      String? token = await AuthService.getToken();
      if (token == null) {
        String? newToken = await AuthService.refreshToken();
        if (newToken == null ||
            newToken == "" ||
            newToken == "Refresh failed") {
          throw Exception("Error when fetching order at table");
        } else {
          //http://localhost:3333
          //https://quannhauserver.xyz
          final response = await http.get(
            Uri.parse("$domain/api/tables/$tableId/currentDetails"),
            headers: {
              'Authorization': newToken,
            },
          );
          if (response.statusCode == 200) {
            int insideStatus = json.decode(response.body)['status'];
            if (insideStatus == 500) {
              print("error1");
              throw Exception("Current table dont have any orders");
            } else {
              String orderId = json.decode(response.body)['data'];
              return orderId;
            }
          } else {
            throw Exception('Failed to load order of this table');
          }
        }
      } else {
        final response = await http.get(
          //http://localhost:3333
          //https://quannhauserver.xyz
          Uri.parse("$domain/api/tables/$tableId/currentDetails"),
          headers: {
            'Authorization': token,
          },
        );
        if (response.statusCode == 200) {
          int insideStatus = json.decode(response.body)['status'];
          if (insideStatus == 500) {
            print("error2");
            throw Exception("Current table dont have any orders");
          } else {
            String orderId = json.decode(response.body)['data'];
            return orderId;
          }
        } else {
          throw Exception('Failed to load order of this table');
        }
      }
    } catch (e) {
      throw Exception("Error when fetching order at table $tableId: $e");
    }
  }

  Future<String> createOrder(String? tableId, String? note) async {
    try {
      note ??= "";
      print(note);
      if (tableId == null || tableId == "") throw Exception("Missing field");
      String? token = await AuthService.getToken();
      if (token == null) {
        token = await AuthService.refreshToken();
        if (token == null || token == "" || token == "Refresh failed") {
          throw Exception("Error when create order");
        }
      }
      final response = await http.post(
        //http://localhost:3333
        //https://quannhauserver.xyz
        Uri.parse('$domain/api/orders'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tableId': tableId,
          'customerId': "", // Giả sử hàm này trả về ID người dùng hiện tại
          'discountApplied': 0.0,
          'totalAmount': 0.0,
          'note': note,
        }),
      );

      if (response.statusCode == 200) {
        dynamic jsonResponse = jsonDecode(response.body);

        return jsonResponse['data']['id'];
      } else {
        throw Exception('Create order failed');
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
