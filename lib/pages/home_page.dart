import 'package:flutter/material.dart';
import 'menu_page.dart';
import 'order_page.dart';
import 'order_list.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String token;

  const HomePage({super.key, required this.username, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //this keep track of current page to display;
  int _selectedIndex = 0;

  //now we create a method to change _selectedIndex
  void _navigateBottomBar(int index) {
    //bth demo stateless nhung ma minh lam
    //method nay nen can chuyen sang stateful dang stateless bam ctrl . thi no se hien goi y convert to stateful
    setState(() {
      _selectedIndex = index;
    });
  }

  final List _pages = [
    const OrderPage(),
    const OrderListPage(),
    const MenuPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Center(
          child: Text(
            "Welcome, ${widget.username}",
            textAlign: TextAlign.center,
          ),
        ),
      ),
      //bottom navigator bar
      //body of this section
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        items: const [
          //Order
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Order',
          ),

          //Order List
          BottomNavigationBarItem(
            icon: Icon(Icons.blinds_closed_outlined),
            label: 'Order List',
          ),

          //Menu
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Menu',
          ),

          //Profile
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.blue, // Màu sắc khi mục được chọn
        unselectedItemColor: Colors.grey, // Màu sắc khi mục không được chọn
        backgroundColor:
            Colors.white, // Màu nền cho toàn bộ BottomNavigationBar
        type: BottomNavigationBarType
            .fixed, // Đảm bảo các mục không thay đổi vị trí
      ),
    );
  }
}
