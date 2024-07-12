import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import '../datas/user_data.dart';
import '../datas/notification_data.dart'; // Import lớp Notification và fetchNotifications
import 'package:swd_group_project/network_services/network_monitor.dart';

class NotificationPage extends StatefulWidget {
  final User user; // User data

  const NotificationPage({Key? key, required this.user}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationItem> _notifications = [];
  List<NotificationItem> _filteredNotifications = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  //  String domain = "http://localhost:3333";
  String domain = "https://quannhauserver.xyz";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterNotifications);

    requestNotificationPermission(); // Yêu cầu quyền thông báo

    // Lấy FCM token khi khởi động trang
    _retrieveAndSendFCMToken();

    // Lắng nghe các tin nhắn FCM mới
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleIncomingNotification(message);
    });

    // Tải thông báo từ file
    _loadNotifications();
  }

  // Hàm yêu cầu quyền thông báo từ người dùng
  Future<void> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for notifications');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    await _loadNotificationsFromFile();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _retrieveAndSendFCMToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        try {
          await sendTokenToServer(token);
          print("fcm token: " + token);
        } catch (e) {
          print('Error sending FCM token: $e');
        }
      } else {
        print('FCM token is null');
      }
    } catch (e) {
      print("Error message: $e");
    }
  }

  //local //http://localhost:3333
  //deploy //https://quannhauserver.xyz
  Future<void> sendTokenToServer(String token) async {
    final url = Uri.parse('$domain/api/notifications/save-fcm-token/');
    final body = jsonEncode({'userId': widget.user.id, 'fcmToken': token});

    try {
      final response = await http.post(url, body: body, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        print('FCM token sent successfully: user id: ${widget.user.id}');
      } else {
        print('Failed to send FCM token. Status code: ${response.statusCode}');
        throw Exception('Failed to send FCM token');
      }
    } catch (e) {
      print('Error sending FCM token: $e');
      throw Exception('Error sending FCM token: $e');
    }
  }

  void _filterNotifications() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotifications = _notifications.where((notification) {
        return notification.tableName.toLowerCase().contains(query) ||
            notification.productName.toLowerCase().contains(query) ||
            notification.status.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _handleIncomingNotification(RemoteMessage message) async {
    try {
      setState(() {
        _notifications.insert(
          0, // Thêm vào đầu danh sách để thông báo mới nhất hiển thị đầu tiên
          NotificationItem(
            tableName: message.data['tableName'] ?? '',
            productName: message.data['productName'] ?? '',
            quantity: int.tryParse(message.data['quantity'] ?? '0') ?? 0,
            status: message.data['status'] ?? '',
            timestamp: DateTime.now(), // Thêm timestamp hiện tại
          ),
        );
        _filteredNotifications =
            List.from(_notifications); // Cập nhật danh sách lọc
      });

      // Lưu lại thông báo vào tệp
      await _saveNotificationsToFile();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _saveNotificationsToFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/notifications.json');

      // Chuyển đổi danh sách _notifications thành danh sách JSON
      final jsonNotifications =
          _notifications.map((notification) => notification.toJson()).toList();

      // Ghi dữ liệu vào tệp
      await file.writeAsString(jsonEncode(jsonNotifications));
      print('Notifications saved to file');
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  Future<void> _loadNotificationsFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/notifications.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        final jsonNotifications = jsonDecode(contents) as List<dynamic>;
        setState(() {
          _notifications = jsonNotifications
              .map((json) => NotificationItem.fromJson(json))
              .toList();
          _filteredNotifications = List.from(_notifications);
        });
      }
    } catch (e) {
      print("Error in notification page: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = Provider.of<NetworkMonitor>(context).isConnected;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.green[800],
          ),
        ),
        title: const Center(
          child: Text(
            "Notification",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!isConnected)
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Lost internet connection',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredNotifications.isEmpty
                      ? const Center(child: Text('No notifications found'))
                      : ListView.builder(
                          itemCount: _filteredNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = _filteredNotifications[index];
                            return Container(
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.only(bottom: 5.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${notification.tableName} - ${notification.productName}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Status: ${notification.status}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Received at: ${notification.timestamp}', // Hiển thị timestamp
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
