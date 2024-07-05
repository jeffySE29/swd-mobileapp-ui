import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import '../datas/user_data.dart';
import 'home_page.dart';
import '../datas/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  void login(String username, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      Response response = await post(
        Uri.parse('https://quannhauserver.xyz/api/auth/login'),
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        int bodyStatusCode = responseBody['statusCode'];
        var data = responseBody['data'];
        String token = data['token'];
        String refreshToken = data['refreshToken'];
        DateTime expiresAt = DateTime.parse(data['expiresAt']);
        var account = data['account'];

        if (bodyStatusCode == 200) {
          await AuthService.saveToken(token, expiresAt, refreshToken);
          User user = User.fromJson(account);
          await user.getAvatar();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(user: user),
              ),
            );
          });
        } else {
          setState(() {
            _showErrorMessage("Invalid username or password");
          });
        }
      } else {
        setState(() {
          _showErrorMessage("Check your connection");
        });
      }
    } catch (e) {
      setState(() {
        _showErrorMessage("Error when login. Please try later!");
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    Flushbar(
      message: message,
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10), // Add space above the logo
            const Image(
              image: AssetImage(
                  'lib/images/logo.jpg'), // Đường dẫn có thể cần điều chỉnh
              width: 200, // Đặt kích thước lớn hơn 2 lần so với ban đầu
              height: 200,
            ),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Login to order!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      border: InputBorder.none,
                      fillColor: Colors.white, // Set background color
                      filled: true, // Enable filling
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 20.0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: InputBorder.none,
                      fillColor: Colors.white, // Set background color
                      filled: true, // Enable filling
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 20.0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      if (usernameController.text.toString().isEmpty) {
                        _showErrorMessage("User name is required");
                      } else if (passwordController.text.toString().isEmpty) {
                        _showErrorMessage("Password is required");
                      } else {
                        login(usernameController.text, passwordController.text);
                      }
                    },
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.teal[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: _isLoading
                            ? CircularProgressIndicator()
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
