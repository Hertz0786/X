import 'package:flutter/material.dart';
import 'screens/first.dart';  // Màn hình đầu tiên
import 'screens/login.dart';  // Màn hình đăng nhập
import 'screens/main_navigation.dart'; // Màn hình chính sau khi đăng nhập thành công

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstScreen(), // Màn hình đầu tiên khi mở ứng dụng
    );
  }
}
