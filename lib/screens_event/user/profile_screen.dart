import 'package:flutter/material.dart';
import 'edit_profile_screen.dart'; // Import màn hình chỉnh sửa hồ sơ

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Hồ sơ", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar và tên người dùng
            const Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.purple,
                child: Text('H', style: TextStyle(color: Colors.white, fontSize: 30)),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                "Nguyễn Tiến Dầu", // Tên người dùng
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "@nguyentien", // Tên hiển thị (username)
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),

            // Thông tin khác (ví dụ: email, số điện thoại)
            const Text(
              "Thông tin liên lạc:",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Email: example@example.com", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            const Text("Số điện thoại: 0123456789", style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 30),
            // Nút chỉnh sửa hồ sơ
            ElevatedButton(
              onPressed: () {
                // Mở màn hình chỉnh sửa hồ sơ khi bấm vào nút này
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Chỉnh sửa hồ sơ", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
