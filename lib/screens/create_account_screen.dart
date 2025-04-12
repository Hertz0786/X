import 'package:flutter/material.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  // Tạo tài khoản khi nhấn nút "Tiếp theo"
  void _createAccount() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final birthdate = _birthdateController.text.trim();

    if (name.isEmpty || email.isEmpty || birthdate.isEmpty) {
      // Nếu có trường nào đó bỏ trống, hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
    } else {
      // Nếu thông tin hợp lệ, tiếp tục sang màn hình tiếp theo (ví dụ: chuyển sang MainScreen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()), // Chuyển sang màn hình chính
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước
          },
        ),
        centerTitle: true,
        title: const Text("Tạo tài khoản của bạn", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên người dùng
            const Text("Tên:", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Nhập tên của bạn",
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Email
            const Text("Email:", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Nhập email của bạn",
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Ngày sinh
            const Text("Ngày sinh:", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              controller: _birthdateController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Nhập ngày sinh của bạn",
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const Spacer(),
            // Nút Tiếp theo
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _createAccount,
              child: const Center(
                child: Text('Tiếp theo', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
      ),
      body: const Center(
        child: Text('Chào mừng bạn đến với ứng dụng!'),
      ),
    );
  }
}
