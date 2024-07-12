import 'package:flutter/material.dart';
import 'notification_page.dart';
import 'order_page.dart';
import 'order_list_page.dart';
import 'profile_page.dart';
import '../datas/user_data.dart';

class HomePage extends StatefulWidget {
  final User user; // User data
  final int initialTabIndex; // Tab index to select initially

  const HomePage({super.key, required this.user, this.initialTabIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
  }

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      OrderPage(user: widget.user),
      OrderListPage(user: widget.user),
      NotificationPage(user: widget.user),
      ProfilePage(user: widget.user), // Pass user data to ProfilePage
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.blinds_closed_outlined),
            label: 'Order List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
