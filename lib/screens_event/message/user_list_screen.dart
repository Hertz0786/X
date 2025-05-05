import 'package:flutter/material.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/auth/auth_me_api.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';
import 'package:kotlin/screens_event/message/chat_detail_screen.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<GetMeObject> _users = [];
  List<GetMeObject> _filteredUsers = [];
  GetMeObject? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadUsers();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthMeApi(apiClient: ApiClient()).fetchCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _loadUsers() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) throw Exception("Chưa đăng nhập");

      final res = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/messages/users"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        final users = list.map((e) => GetMeObject.fromJson(e)).toList();
        setState(() {
          _users = users;
          _filteredUsers = users;
        });
      } else {
        throw Exception("Lỗi khi tải người dùng: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ User load error: $e");
    }
  }

  void _filterUsers(String query) {
    final filtered = _users.where((user) {
      final name = user.fullname?.toLowerCase() ?? '';
      final username = user.username?.toLowerCase() ?? '';
      return name.contains(query.toLowerCase()) || username.contains(query.toLowerCase());
    }).toList();

    setState(() => _filteredUsers = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Chọn người để nhắn", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Tìm kiếm người dùng...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterUsers,
            ),
          ),
          Expanded(
            child: _filteredUsers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
              itemCount: _filteredUsers.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.grey),
              itemBuilder: (_, index) {
                final user = _filteredUsers[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          receiverId: user.id,
                          receiverName: user.fullname ?? user.username,
                          receiverAvatar: user.profileImg,
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundImage: user.profileImg != null
                        ? NetworkImage(user.profileImg!)
                        : null,
                    backgroundColor: Colors.purple,
                    child: user.profileImg == null
                        ? Text(
                      user.fullname?[0].toUpperCase() ?? 'U',
                      style: const TextStyle(color: Colors.white),
                    )
                        : null,
                  ),
                  title: Text(
                    user.fullname ?? user.username,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    user.email ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
