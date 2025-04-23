import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'liked_post_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Giả lập số liệu — thay bằng dữ liệu thật nếu có
    final int postCount = 12;
    final int likedCount = 47;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Hồ sơ", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.purple,
              child: Text('H', style: TextStyle(color: Colors.white, fontSize: 30)),
            ),
            const SizedBox(height: 16),
            const Text(
              "Nguyễn Tiến Dầu",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "@nguyentien",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Thống kê
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat("Bài viết", postCount),
                _buildStat("Đã thích", likedCount),
              ],
            ),

            const SizedBox(height: 30),

            // Thông tin liên hệ
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Thông tin liên lạc:",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("Email: example@example.com", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text("Số điện thoại: 0123456789", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Nút chỉnh sửa
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LikedPostsScreen()),
                );
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
        ),
      ),
    );
  }

  Widget _buildStat(String label, int count) {
    return Column(
      children: [
        Text(
          "$count",
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
