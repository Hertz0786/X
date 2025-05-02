import 'package:flutter/material.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/auth/sign_up_oj.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}
///////////lost token
class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  ApiClient apiClient = ApiClient();

  // Tạo tài khoản khi nhấn nút "Tiếp theo"
  Future<void> _createAccount() async {
  final fullname = _fullnameController.text.trim();
  final email = _emailController.text.trim();
  final username = _usernameController.text.trim();
  final password = _passwordController.text.trim();

  if ([fullname, email, username, password].any((field) => field.isEmpty)) {
    _showError("Vui lòng điền đầy đủ thông tin" , context);
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
      fromJson: SignUpObject.fromJson,
      body: signupData.toJson(),
    );

    if (res != null) {
      debugPrint("Đăng ký thành công: ${res.email}");
      _goToMainScreen(context);
    } else {
      _showError("Đăng ký thất bại, vui lòng thử lại." ,context);
    }
  } catch (e) {
    _showError("Lỗi kết nối đến server: $e",context);
  }
}

/////////////////////
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
        title: const Text(
          "Tạo tài khoản của bạn",
          style: TextStyle(color: Colors.white),
        ),
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
              controller: _fullnameController,
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
            const Text("Tên tài khoản:", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Nhập tên tài khoản của bạn",
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const Text("Mật khẩu:", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Nhập mật khẩu của bạn",
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
      appBar: AppBar(title: const Text('Main Screen')),
      body: const Center(child: Text('Chào mừng bạn đến với ứng dụng!')),
    );
  }
}
void _showError(String message , BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

void _goToMainScreen(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const MainScreen()),
  );
}
