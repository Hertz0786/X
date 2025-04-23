import 'package:flutter/material.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/client/post/create_post_api.dart';

class ComposePostScreen extends StatefulWidget {
  final String token;
  const ComposePostScreen({super.key, required this.token});

  @override
  State<ComposePostScreen> createState() => _ComposePostScreenState();
}

class _ComposePostScreenState extends State<ComposePostScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _imagePath;

  void _submitPost() async {
    final content = _controller.text.trim();

    if (content.isEmpty && _imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng cung cấp nội dung hoặc ảnh')),
      );
      return;
    }

    try {
      final postData = CreatePostObject(
        text: content,
        image: _imagePath,
        token: widget.token,
      );

      final response = await CreatePostApi(apiClient: ApiClient()).createPost(postData);

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bài viết đã được tạo')),
        );
        Navigator.pop(context, true); // ✅ trả về để gọi fetchPosts()
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tạo bài viết')),
        );
      }
    } catch (error) {
      print('Lỗi khi tạo bài viết: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tạo bài viết: $error')),
      );
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
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: null,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Chuyện gì đang xảy ra?",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: dùng image_picker tại đây nếu cần
              },
              child: const Text("Chọn ảnh"),
            ),
          ],
        ),
      ),
    );
  }
}
