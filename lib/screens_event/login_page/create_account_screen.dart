import 'package:flutter/material.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/auth/sign_up_oj.dart';
import 'package:kotlin/api/dto/auth/login_oj.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/client/id_storage.dart';
import 'package:kotlin/api/client/auth/auth_login_api.dart';
import 'package:kotlin/screens_event/main_navigation.dart'; // 👈 sửa tại đây

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiClient apiClient = ApiClient();
  final AuthApi _authApi = AuthApi();

  Future<void> _createAccount() async {
    final fullname = _fullnameController.text.trim();
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if ([fullname, email, username, password].any((field) => field.isEmpty)) {
      _showError("Vui lòng điền đầy đủ thông tin", context);
      return;
    }

    final signupData = SignUpObject(
      username: username,
      fullname: fullname,
      password: password,
      email: email,
    );

    try {
      final res = await apiClient.post<SignUpObject>(
        "/api/auth/signup",
        fromJson: (json) => SignUpObject.fromJson(json as Map<String, dynamic>),
        body: signupData.toJson(),
        token: null,
      );

      if (res != null) {
        debugPrint("Đăng ký thành công: ${res.email}");

        final loginObject = LoginObject(username: username, password: password);
        final loginRes = await _authApi.login(loginObject);

        final token = loginRes['accessToken'] ?? loginRes['token'];
        final userId = loginRes['_id'] ?? loginRes['userId'] ?? loginRes['_Id'];

        if (token != null && userId != null) {
          await TokenStorage.saveToken(token);
          await IdStorage.saveUserId(userId);
          debugPrint("✅ Token và ID đã được lưu sau khi login");
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()), // 👈 vào đúng màn chính
        );
      } else {
        _showError("Đăng ký thất bại, vui lòng thử lại.", context);
      }
    } catch (e) {
      _showError("Lỗi đăng ký hoặc login: $e", context);
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
        title: const Text("Tạo tài khoản của bạn", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInput("Tên:", _fullnameController, "Nhập tên của bạn"),
            const SizedBox(height: 20),
            _buildInput("Email:", _emailController, "Nhập email của bạn"),
            const SizedBox(height: 20),
            _buildInput("Tên tài khoản:", _usernameController, "Nhập tên tài khoản của bạn"),
            const SizedBox(height: 20),
            _buildInput("Mật khẩu:", _passwordController, "Nhập mật khẩu của bạn", obscure: true),
            const Spacer(),
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

  Widget _buildInput(String label, TextEditingController controller, String hint, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

void _showError(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
