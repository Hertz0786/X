import 'package:flutter/material.dart';
import 'x_ui.dart';
import 'notification/notification_screen.dart';
import 'message/message_screen.dart';
import 'post/compose_post_screen.dart';
import 'search/saearch_screen.dart'; // Import màn hình tìm kiếm
import 'login_page/first.dart';  // Import màn hình đăng nhập để quay lại khi đăng xuất
//import 'package:shared_preferences/shared_preferences.dart';  // Import SharedPreferences để lấy token
import 'package:kotlin/api/client/token_storage.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    XUI(),
    NotificationScreen(),
    MessageScreen(),
  ];

  // Hàm điều hướng khi nhấn nút tìm kiếm ở BottomNavigationBar
  void _onSearchPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  // Hàm đăng xuất, chuyển về màn hình đăng nhập
  void _logout() async {
    // Xóa token khi đăng xuất
    await TokenStorage.removeToken();

    // Kiểm tra token đã được xóa chưa
    await checkToken(); // Gọi hàm kiểm tra token sau khi xóa

    // Chuyển về màn hình đăng nhập
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FirstScreen()),
    );
  }

  // Hàm kiểm tra token đã bị xóa
  Future<void> checkToken() async {
    // Lấy token từ SharedPreferences
    String? token = await TokenStorage.getToken();

    // Kiểm tra token đã bị xóa chưa
    if (token == null) {
      print("Token đã bị xóa khỏi SharedPreferences.");
    } else {
      print("Token vẫn còn trong SharedPreferences: $token");
    }
  }

  // Hàm lấy token từ SharedPreferences
  Future<String?> _getToken() async {
    return await TokenStorage.getToken();  // Sử dụng TokenStorage để lấy token
  }

  // Hàm điều hướng sau khi lấy token
  void _navigateToComposePostScreen(String token) {
    // Đảm bảo sử dụng context trước khi gọi async
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ComposePostScreen(token: token)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Trang Chính", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),  // Nút đăng xuất
            onPressed: _logout,  // Gọi hàm đăng xuất
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Lấy token trước khi thực hiện điều hướng
          String? token = await _getToken();

          // Điều hướng ngay sau khi lấy token
          if (token != null) {
            // Chuyển đến ComposePostScreen nếu token có sẵn
            _navigateToComposePostScreen(token);
          } else {
            // Token không tồn tại, có thể thông báo lỗi hoặc chuyển đến màn hình đăng nhập
            _logout();
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            // Nếu ấn vào tab tìm kiếm, gọi hàm _onSearchPressed()
            _onSearchPressed();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: ""),
        ],
      ),
    );
  }
}