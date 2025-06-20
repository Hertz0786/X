import 'package:flutter/material.dart';
import 'package:kotlin/screens_event/main_navigation.dart';
import 'forgot_password.dart';
import 'package:kotlin/api/dto/auth/login_oj.dart';
import 'package:kotlin/api/client/auth/auth_login_api.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/client/id_storage.dart';
import 'package:kotlin/api/client/Socket.dart'; // 🔌 Thêm dòng này

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthApi _authApi = AuthApi();

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập email và mật khẩu")),
      );
      return;
    }

    final loginObject = LoginObject(username: email, password: password);

    try {
      final response = await _authApi.login(loginObject);
      print("🔁 Phản hồi từ API login: $response");

      final token = response['accessToken'] ?? response['token'];
      final userId = response['_Id'] ?? response['_id'];

      if (token == null || userId == null) {
        print("❌ Thiếu token hoặc userId trong phản hồi");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể đăng nhập: thiếu dữ liệu")),
        );
        return;
      }

      await TokenStorage.saveToken(token);
      await IdStorage.saveUserId(userId);
      print("✅ Token đã lưu: $token");
      print("🧾 ID người dùng đã lưu: $userId");

      // 🔌 Kết nối socket
      await SocketService().connect();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    } catch (e, stack) {
      print("🔥 Lỗi khi login: $e");
      print("📌 Stacktrace: $stack");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đăng nhập: $e")),
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
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Icon(Icons.clear, color: Colors.white, size: 30),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Để bắt đầu, trước tiên hãy nhập số điện thoại, email hoặc @tên người dùng của bạn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Số điện thoại, email hoặc tên người dùng',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Mật khẩu',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                );
              },
              child: const Text('Quên mật khẩu?', style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _login,
              child: const Center(
                child: Text('Đăng nhập', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
