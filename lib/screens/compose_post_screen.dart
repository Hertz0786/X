import 'package:flutter/material.dart';

class ComposePostScreen extends StatefulWidget {
  const ComposePostScreen({super.key});

  @override
  State<ComposePostScreen> createState() => _ComposePostScreenState();
}

class _ComposePostScreenState extends State<ComposePostScreen> {
  final TextEditingController _controller = TextEditingController();

  void _submitPost() {
    final content = _controller.text.trim();
    if (content.isNotEmpty) {
      // TODO: Bạn có thể gửi nội dung này lên server hoặc thêm vào danh sách bài viết
      print('Đã đăng bài: $content');
      Navigator.pop(context); // Quay lại sau khi đăng
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Tạo bài viết"),
        actions: [
          TextButton(
            onPressed: _submitPost,
            child: const Text("Đăng", style: TextStyle(color: Colors.blue)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _controller,
          maxLines: null,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Chuyện gì đang xảy ra?",
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
