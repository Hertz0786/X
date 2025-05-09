import 'package:flutter/material.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';
import 'package:kotlin/api/client/auth/auth_me_api.dart';
import 'package:kotlin/api/client/user/get_user.dart'; // Import GetUser để dùng fetchProfileById
import 'package:kotlin/api/client/id_storage.dart'; // Import IdStorage để lấy userId
import 'edit_profile_screen.dart';
import 'liked_post_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId; // Tham số userId để xác định xem người dùng đang xem profile của ai

  const ProfileScreen({super.key, required this.userId}); // Nhận userId từ màn hình gọi

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GetMeObject? user;
  bool isLoading = true;
  String? currentUserId; // Thêm biến để lưu currentUserId

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId(); // Gọi hàm để lấy currentUserId
    fetchUserInfo();
  }

  // Lấy currentUserId từ IdStorage
  Future<void> _loadCurrentUserId() async {
    final id = await IdStorage.getUserId();  // Lấy userId từ SharedPreferences
    setState(() {
      currentUserId = id;
    });
  }

  // Lấy thông tin người dùng: nếu là profile của chính mình, dùng AuthMeApi, nếu là của người khác, dùng GetUser
  Future<void> fetchUserInfo() async {
    try {
      if (widget.userId == currentUserId) {
        // Nếu userId là của chính mình, dùng AuthMeApi
        final api = AuthMeApi(apiClient: ApiClient());
        final me = await api.fetchCurrentUser();
        setState(() {
          user = me;
          isLoading = false;
        });
      } else {
        // Nếu userId là của người khác, dùng GetUser
        final api = GetUser(apiClient: ApiClient());
        final otherUser = await api.fetchProfileById(widget.userId);
        setState(() {
          user = otherUser;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi khi load user: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Hồ sơ", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? const Center(child: Text("Không thể tải thông tin người dùng", style: TextStyle(color: Colors.white)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.purple,
              backgroundImage: (user!.profileImg != null && user!.profileImg!.isNotEmpty)
                  ? NetworkImage(user!.profileImg!)
                  : null,
              child: (user!.profileImg == null || user!.profileImg!.isEmpty)
                  ? Text(user!.username[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 30))
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user!.fullname ?? user!.username,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text("@${user!.username}", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat("Bài viết", 0), // Giả sử số lượng bài viết
                _buildStat("Đã thích", 0),  // Giả sử số bài viết đã thích
              ],
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Thông tin liên lạc:",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("Email: ${user!.email}", style: const TextStyle(color: Colors.grey)),
                  if (user!.bio != null && user!.bio!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text("Bio: ${user!.bio}", style: const TextStyle(color: Colors.grey)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Chỉ hiển thị nút "Chỉnh sửa hồ sơ" và "Bài viết đã thích" nếu đang xem hồ sơ của chính mình
            if (widget.userId == currentUserId) ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text("Chỉnh sửa hồ sơ", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const LikedPostsScreen()));
                },
                icon: const Icon(Icons.favorite, color: Colors.white),
                label: const Text("Bài viết đã thích", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int count) {
    return Column(
      children: [
        Text("$count", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
