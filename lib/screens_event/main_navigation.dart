import 'package:flutter/material.dart';
import 'x_ui.dart';
import 'notification/notification_screen.dart';
import 'message/message_screen.dart';
import 'post/compose_post_screen.dart';
import 'search/search_screen.dart';
import 'login_page/first.dart';
import 'user/profile_screen.dart';
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
      XUI(key: _xuiKey),
      const SearchScreen(),
      const NotificationScreen(),
      const MessageScreen(),
    ];
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await TokenStorage.getToken();
    final userId = await IdStorage.getUserId();

    debugPrint("✅ Token: $token");
    debugPrint("🧾 User ID: $userId");

    if (token == null || userId == null) {
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

  Future<void> _navigateToComposePostScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ComposePostScreen()),
    );

    if (result == true) {
      if (_currentIndex == 0) {
        _xuiKey.currentState?.fetchAllPosts();
      } else {
        setState(() => _currentIndex = 0);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _xuiKey.currentState?.fetchAllPosts();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: const Text("", style: TextStyle(color: Colors.white)),
        leading: GestureDetector(
          onTap: () async {
            // Lấy userId từ IdStorage
            final userId = await IdStorage.getUserId();
            if (userId != null) {
              // Truyền userId vào ProfileScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userId: userId),  // Truyền userId vào ProfileScreen
                ),
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToComposePostScreen,
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
          if (index < _screens.length) {
            setState(() => _currentIndex = index);
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
