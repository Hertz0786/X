// import 'package:flutter/material.dart';
// import 'screens/first.dart'; // Import FirstScreen
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: FirstScreen(), // Gọi màn hình đầu tiên
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainNavigationScreen(),
    );
  }
}

// phần còn lại giữ nguyên...
