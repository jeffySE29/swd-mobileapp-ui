import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

// const String domain = "http://localhost:3333";
const String domain = "https://quannhauserver.xyz";

class User {
  final String id;
  final String email;
  final String username;
  final String name;
  final String phone;
  String avatarUrl;
  final String role;
  final String defaultAvatar =
      'https://inkythuatso.com/uploads/thumbnails/800/2023/03/6-anh-dai-dien-trang-inkythuatso-03-15-26-36.jpg';

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.phone,
    required this.avatarUrl,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      name: json['name'],
      phone: json['phone'],
      avatarUrl: json['avatarUrl'], //có thể null
      role: json['role'],
    );
  }

  String getCurrentUserId() {
    return id;
  }

  Future<void> getAvatar() async {
    try {
      String? token = await AuthService.getToken();
      if (token == null) {
        String? newToken = await AuthService.refreshToken();
        if (newToken == null ||
            newToken == "" ||
            newToken == "Refresh failed") {
          throw Exception("Error when get avatar");
        } else {
          //http://localhost:3333
          //https://quannhauserver.xyz
          final response = await http.get(
            Uri.parse('$domain/api/users/avatar/$id'),
            headers: {
              'Authorization': newToken,
            },
          );
          if (response.statusCode == 200) {
            final responseBody = jsonDecode(response.body);
            String data = responseBody['data'];
            if (data == null || data == "") {
              avatarUrl =
                  'https://inkythuatso.com/uploads/thumbnails/800/2023/03/6-anh-dai-dien-trang-inkythuatso-03-15-26-36.jpg';
            } else {
              avatarUrl = data;
            }
          } else {
            avatarUrl =
                'https://inkythuatso.com/uploads/thumbnails/800/2023/03/6-anh-dai-dien-trang-inkythuatso-03-15-26-36.jpg';
          }
        }
      } else {
        final response = await http.get(
          //http://localhost:3333
          //https://quannhauserver.xyz
          Uri.parse('$domain/api/users/avatar/$id'),
          headers: {
            'Authorization': token,
          },
        );
        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          String data = responseBody['data'];
          if (data == null || data == "") {
            avatarUrl =
                'https://inkythuatso.com/uploads/thumbnails/800/2023/03/6-anh-dai-dien-trang-inkythuatso-03-15-26-36.jpg';
          } else {
            avatarUrl = data;
          }
        } else {
          avatarUrl =
              'https://inkythuatso.com/uploads/thumbnails/800/2023/03/6-anh-dai-dien-trang-inkythuatso-03-15-26-36.jpg';
        }
      }
    } catch (e) {
      print("Error when get avatar: $e");
      throw Exception("Error when get avatar: $e");
    }
  }

  Future<String?> logout() async {
    try {
      String? token = await AuthService.getToken();
      if (token == null) {
        String? newToken = await AuthService.refreshToken();
        if (newToken == null ||
            newToken == "" ||
            newToken == "Refresh failed") {
          return "success";
        } else {
          //http://localhost:3333
          //https://quannhauserver.xyz
          final response = await http.post(
            Uri.parse('$domain/api/auth/logout'),
            headers: {
              'Authorization': newToken,
            },
          );
          if (response.statusCode == 200) {
            final responseBody = jsonDecode(response.body);
            String responseMessage = responseBody['message'];
            if (responseMessage == "Logged out!") {
              return "success";
            }
          }
        }
      } else {
        final response = await http.post(
          //http://localhost:3333
          //https://quannhauserver.xyz
          Uri.parse('$domain/api/auth/logout'),
          headers: {
            'Authorization': token,
          },
        );
        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          String responseMessage = responseBody['message'];
          if (responseMessage == "Logged out!") {
            return "success";
          }
        }
      }
    } catch (e) {
      print("Error when logout: $e");
      throw Exception("Error when logout: $e");
    }
    return null;
  }
}
