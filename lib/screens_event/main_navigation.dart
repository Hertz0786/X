import 'package:flutter/material.dart';
import 'x_ui.dart';
import 'notification/notification_screen.dart';
import 'message/message_screen.dart';
import 'post/compose_post_screen.dart';
import 'search/saearch_screen.dart';
import 'login_page/first.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/client/id_storage.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<XUIState> _xuiKey = GlobalKey<XUIState>();
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      XUI(key: _xuiKey),               // index 0: Home
      const Offstage(),                // index 1: Hidden placeholder
      const NotificationScreen(),      // index 2: Notifications
      const MessageScreen(),           // index 3: Messages
    ];
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await TokenStorage.getToken();
    final userId = await IdStorage.getUserId();

    print("✅ Token đã lưu: $token");
    print("🧾 User ID đã lưu: $userId");

    if (token == null || userId == null) {
      print("❌ Token hoặc User ID không tồn tại. Quay lại đăng nhập.");
      _logout();
    }
  }

  void _logout() async {
    await TokenStorage.removeToken();
    await IdStorage.removeUserId();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const FirstScreen()),
    );
  }

  void _onSearchPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  void _navigateToComposePostScreen(String token) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ComposePostScreen(token: token)),
    );

    if (result == true) {
      if (_currentIndex == 0) {
        _xuiKey.currentState?.fetchPosts();
      } else {
        setState(() => _currentIndex = 0);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _xuiKey.currentState?.fetchPosts();
        });
      }
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
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final token = await TokenStorage.getToken();
          if (token != null) {
            _navigateToComposePostScreen(token);
          } else {
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
            _onSearchPressed(); // Mở màn tìm kiếm riêng
          } else if (index < _screens.length) {
            setState(() => _currentIndex = index);
          } else {
            print("⚠️ Index không hợp lệ: $index");
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
