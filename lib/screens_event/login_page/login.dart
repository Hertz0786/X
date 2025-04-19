import 'package:flutter/material.dart';
import 'package:kotlin/screens_event/main_navigation.dart';
import 'forgot_password.dart'; // Import màn hình Quên mật khẩu
import 'package:kotlin/api/dto/auth/login_oj.dart';
import 'package:kotlin/api/client/auth/auth_login_api.dart';
import 'package:kotlin/api/client/token_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthApi _authApi = AuthApi(); // Khởi tạo AuthApi

  // Hàm đăng nhập sử dụng LoginObject
  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập email và mật khẩu")),
      );
      return;
    }

    // Tạo đối tượng LoginObject
    final loginObject = LoginObject(username: email, password: password);

    try {
      final response = await _authApi.login(loginObject); // Gọi login API với LoginObject

      if (response != null && response['token'] != null) {
        final token = response['token'];

        // Lưu token vào SharedPreferences thông qua TokenStorage
        await TokenStorage.saveToken(token);

        // Kiểm tra lại token đã được lưu
        await checkToken(); // Gọi hàm checkToken để kiểm tra token

        // Sau khi đăng nhập thành công, bạn có thể chuyển hướng đến màn hình chính
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sai email hoặc mật khẩu")),
        );
      }
    } catch (e) {
      // Hiển thị lỗi nếu đăng nhập thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xảy ra lỗi khi đăng nhập")),
      );
    }
  }

  // Kiểm tra token đã lưu
  Future<void> checkToken() async {
    String? token = await TokenStorage.getToken();
    if (token != null) {
      print('Token đã được lưu: $token');
    } else {
      print('Token chưa được lưu');
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
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text(
                'Quên mật khẩu?',
                style: TextStyle(color: Colors.grey),
              ),
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
              onPressed: _login, // Gọi hàm đăng nhập khi bấm nút
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
