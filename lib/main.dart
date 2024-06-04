import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/menu_page.dart';
import 'pages/order_list.dart';
import 'pages/order_page.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      onGenerateRoute: (settings) {
        if (settings.name == '/home_page') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) {
              return HomePage(
                username: args['username']!,
                token: args['token']!,
              );
            },
          );
        }

        // Handle other routes here
        switch (settings.name) {
          case '/login_page':
            return MaterialPageRoute(builder: (context) => const LoginPage());
          case '/order_page':
            return MaterialPageRoute(builder: (context) => const OrderPage());
          case '/order_list_page':
            return MaterialPageRoute(
                builder: (context) => const OrderListPage());
          case '/profile_page':
            return MaterialPageRoute(builder: (context) => const ProfilePage());
          case '/menu_page':
            return MaterialPageRoute(builder: (context) => const MenuPage());
          default:
            return MaterialPageRoute(builder: (context) => const LoginPage());
        }
      },
    );
  }
}
