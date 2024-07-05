import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:http/http.dart' as http;
import '../datas/auth_service.dart';
import '../datas/table_list.dart';

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
  final List<TableModel> tables;

  AreaModel({
    required this.name,
    required this.tables,
  });

  factory AreaModel.fromJson(String name, List<dynamic> jsonList) {
    List<TableModel> tables =
        jsonList.map((data) => TableModel.fromJson(data)).toList();
    return AreaModel(name: name, tables: tables);
  }
}

class AreaTable {
  final String baseUrl = "https://quannhauserver.xyz/api/areas/detail/";

  Future<List<AreaModel>> fetchAreas() async {
    try {
      String? token = await AuthService.getToken();
      if (token == null) {
        String? newToken = await AuthService.refreshToken();
        if (newToken == null ||
            newToken == "" ||
            newToken == "Refresh failed") {
          throw Exception("Error when fetch area table");
        } else {
          final response = await http.get(
            Uri.parse(baseUrl),
            headers: {
              'Authorization': '$newToken',
            },
          );
          if (response.statusCode == 200) {
            Map<String, dynamic> data = json.decode(response.body)['data'];
            List<AreaModel> areas = [];

            data.forEach((areaName, tables) {
              areas.add(AreaModel.fromJson(areaName, tables));
            });
            return areas;
          } else {
            throw Exception('Failed to load areas');
          }
        }
      } else {
        final response = await http.get(
          Uri.parse(baseUrl),
          headers: {
            'Authorization': '$token',
          },
        );
        if (response.statusCode == 200) {
          Map<String, dynamic> data = json.decode(response.body)['data'];
          List<AreaModel> areas = [];

          data.forEach((areaName, tables) {
            areas.add(AreaModel.fromJson(areaName, tables));
          });
          return areas;
        } else {
          throw Exception('Failed to load areas');
        }
      }
    } catch (e) {
      throw Exception("Failed to fetch areas: $e");
    }
  }
}
