import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// const String domain = "http://localhost:3333";
const String domain = "https://quannhauserver.xyz";

class AuthService {
  // Function to save token and expiresAt to SharedPreferences
  static Future<void> saveToken(
      String token, DateTime expiresAt, String refreshToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString("expiresAt", expiresAt.toIso8601String());
    await prefs.setString("refreshToken", refreshToken);
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    String? expiresAtString = prefs.getString("expiresAt");
    if (expiresAtString != null) {
      DateTime expiresAt = DateTime.parse(expiresAtString);
      if (DateTime.now().isBefore(expiresAt)) {
        return token;
      }
    }
    return null;
  }

  static Future<String?> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString("refreshToken");
    return refreshToken;
  }

  // Function to refresh token using refreshToken
  static Future<String?> refreshToken() async {
    try {
      String? refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return "Refresh failed";
      }
      //http://localhost:3333
      //https://quannhauserver.xyz
      var response = await http.post(
        Uri.parse('$domain/api/auth/refreshToken'),
        body: {'refreshToken': refreshToken},
      );
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        String message = responseBody['message'];
        if (message == "Success") {
          String newToken = responseBody['data']['token'];
          String newExpiresAtString = responseBody['data']['expiresAt'];
          DateTime newExpiresAt = DateTime.parse(newExpiresAtString);
          await saveToken(newToken, newExpiresAt, refreshToken);
          return newToken;
        } else {
          return "Refresh failed";
        }
      } else {
        return "Refresh failed";
      }
    } catch (e) {
      throw Exception('Error refreshing token: $e');
    }
  }
}
