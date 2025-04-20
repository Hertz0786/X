import 'package:flutter/material.dart';
import 'x_ui.dart';
import 'notification/notification_screen.dart';
import 'message/message_screen.dart';
import 'post/compose_post_screen.dart';
import 'search/saearch_screen.dart';
import 'login_page/first.dart';
import 'package:kotlin/api/client/token_storage.dart';

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
      XUI(key: _xuiKey),
      const NotificationScreen(),
      const MessageScreen(),
    ];
  }

  void _onSearchPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  void _logout() async {
    await TokenStorage.removeToken();
    await checkToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FirstScreen()),
    );
  }

  Future<void> checkToken() async {
    String? token = await TokenStorage.getToken();
    if (token == null) {
      print("Token đã bị xóa khỏi SharedPreferences.");
    } else {
      print("Token vẫn còn trong SharedPreferences: $token");
    }
  }

  Future<String?> _getToken() async {
    return await TokenStorage.getToken();
  }

  void _navigateToComposePostScreen(String token) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ComposePostScreen(token: token)),
    );

    if (result == true) {
      // Nếu đang ở tab Home, chỉ cần reload
      if (_currentIndex == 0) {
        _xuiKey.currentState?.fetchPosts();
      } else {
        // Chuyển về Home rồi reload
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
          String? token = await _getToken();
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
