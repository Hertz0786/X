import 'package:flutter/material.dart';
import 'package:kotlin/screens_event/login_page//first.dart';  // Màn hình đầu tiên
import 'screens_event/login_page/login.dart';  // Màn hình đăng nhập
import 'screens_event/main_navigation.dart'; // Màn hình chính sau khi đăng nhập thành công

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
//// dang o maingator thi k vao dc ho so
////cd D:\Coding\pbl
// npm run dev