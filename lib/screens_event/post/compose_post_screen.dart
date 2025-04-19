import 'package:flutter/material.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/client/post/create_post_api.dart';

class ComposePostScreen extends StatefulWidget {
  final String token; // Token để gửi kèm với yêu cầu tạo bài viết
  const ComposePostScreen({super.key, required this.token});

  @override
  State<ComposePostScreen> createState() => _ComposePostScreenState();
}

class _ComposePostScreenState extends State<ComposePostScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _imagePath; // Lưu trữ đường dẫn ảnh (nếu có)

  // Phương thức để gửi bài viết
  void _submitPost() async {
    final content = _controller.text.trim();
    if (content.isNotEmpty || _imagePath != null) {
      try {
        // Tạo đối tượng CreatePostObject với thông tin từ người dùng
        final postData = CreatePostObject(
          text: content,
          image: _imagePath,
          token: widget.token,
        );

        // Sử dụng CreatePostApi để tạo bài viết
        final apiClient = ApiClient();
        final createPostApi = CreatePostApi(apiClient: apiClient);

        final response = await createPostApi.createPost(postData);

        // Nếu thành công, thông báo và quay lại màn hình trước
        print('Bài viết đã được tạo: ${response.text}');
        Navigator.pop(context);
      } catch (error) {
        print('Không thể tạo bài viết: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tạo bài viết: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng cung cấp nội dung hoặc ảnh')),
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
            // Thêm nút chọn ảnh (nếu cần)
            ElevatedButton(
              onPressed: () {
                // Logic để chọn ảnh và cập nhật _imagePath
                // Bạn có thể dùng plugin image_picker ở đây
                // _imagePath = pickedImagePath;
              },
              child: const Text("Chọn ảnh"),
            ),
          ],
        ),
      ),
    );
  }
}
