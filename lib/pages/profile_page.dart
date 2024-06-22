import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import '../datas/user_data.dart'; // Verify the path to user_data.dart
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  final User user; // User data

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  // Function to call API for logout
  Future<void> logout(BuildContext context) async {
    try {
      String? message =
          await user.logout(); // Call the logout method from the User object
      if (message == "success") {
        // Navigate to login page after successful logout
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      } else {
        // Show Flushbar indicating logout failed
        Flushbar(
          message: 'Logout failed. Please try again.',
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    } catch (e) {
      // Handle API call errors
      print(e);
      Flushbar(
        message: 'An error occurred. Please try again later. $e',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[100],
        title: const Center(
          child: Text(
            "Profile page",
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Container(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(user.avatarUrl),
                //backgroundImage: NetworkImage('https://inkythuatso.com/uploads/thumbnails/800/2023/03/6-anh-dai-dien-trang-inkythuatso-03-15-26-36.jpg'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              user.username,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              user.phone,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                logout(
                    context); // Call the logout function when the button is pressed
              },
              style: ButtonStyle(
                minimumSize: WidgetStateProperty.all<Size>(
                  const Size(250, 50),
                ), // Set the minimum width and height of the button
                backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.teal[100]!), // Màu nền
                foregroundColor:
                    WidgetStateProperty.all<Color>(Colors.black), // Màu chữ
                overlayColor: WidgetStateProperty.all<Color>(Colors.blue[100]!
                    .withOpacity(0.1)), // Màu hiệu ứng khi nhấn
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
