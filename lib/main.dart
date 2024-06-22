import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'pages/login_page.dart';
import 'network_services/network_monitor.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A background message just showed up: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAUG9ufw5az3TJDkJD-fb0jmMPgdoaumos",
        appId: "1:306142775890:android:ed6beee59b6af49eafed8b",
        messagingSenderId: "306142775890",
        projectId: "swd-quannhaurestaurant-se2024",
        storageBucket: "swd-quannhaurestaurant-se2024.appspot.com",
      ),
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    ChangeNotifierProvider(
      create: (_) => NetworkMonitor(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login_page':
            return MaterialPageRoute(builder: (context) => const LoginPage());
          default:
            return MaterialPageRoute(builder: (context) => const LoginPage());
        }
      },
    );
  }
}
