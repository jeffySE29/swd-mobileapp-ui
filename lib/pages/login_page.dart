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
  // String domain = "http://localhost:3333";
  String domain = "https://quannhauserver.xyz";

  void login(String username, String password) async {
    setState(() {
      _isLoading = true;
    });
    // local // http://localhost:3333
    // deploy // https://quannhauserver.xyz
    try {
      Response response = await post(
        Uri.parse('$domain/api/auth/login'),
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        int bodyStatusCode = responseBody['status'];

        if (bodyStatusCode == 200) {
          var data = responseBody['data'];
          String token = data['token'];
          String refreshToken = data['refreshToken'];
          DateTime expiresAt = DateTime.parse(data['expiresAt']);
          var account = data['account'];

          String role = account['role'] ?? "";
          if (role != 'waiters') {
            setState(() {
              _showErrorMessage("Wrong username or password");
            });
            return;
          }
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
        _showErrorMessage("$e");
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
      duration: const Duration(seconds: 2),
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
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10), // Add space above the logo
                const Image(
                  image: AssetImage(
                      'lib/images/logo.png'), // Adjust the path if necessary
                  width: 200, // Larger size for the logo
                  height: 200,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30),
                      const Center(
                        child: Text(
                          'Login to order!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
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
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
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
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
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
                      const SizedBox(height: 80),
                      GestureDetector(
                        onTap: () {
                          if (usernameController.text.toString().isEmpty) {
                            _showErrorMessage("User name is required");
                          } else if (passwordController.text
                              .toString()
                              .isEmpty) {
                            _showErrorMessage("Password is required");
                          } else {
                            login(usernameController.text,
                                passwordController.text);
                          }
                        },
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.green[800],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0, // Increase font size
                                      fontWeight:
                                          FontWeight.bold, // Make text bold
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
        ),
      ),
    );
  }
}
