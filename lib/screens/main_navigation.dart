import 'package:flutter/material.dart';
import 'x_ui.dart';
import 'notification_screen.dart';
import 'message_screen.dart';
import 'compose_post_screen.dart';
import 'saearch_screen.dart'; // Import màn hình tìm kiếm
import 'first.dart';  // Import màn hình đăng nhập để quay lại khi đăng xuất

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
  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FirstScreen()),
    );
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ComposePostScreen()),
          );
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
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Tìm kiếm",  // Nút tìm kiếm nằm trong đây
          ),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: ""),
        ],
      ),
    );
  }
}
