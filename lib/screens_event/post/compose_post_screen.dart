import 'package:flutter/material.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/client/post/create_post_api.dart';
import 'package:kotlin/api/client/token_storage.dart';

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

    // Kiểm tra nếu người dùng nhập nội dung hoặc chọn ảnh
    if (content.isNotEmpty || _imagePath != null) {
      try {
        // Lấy token từ TokenStorage
        final token = await TokenStorage.getToken();

        if (token == null) {
          // Nếu không có token, yêu cầu người dùng đăng nhập lại
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vui lòng đăng nhập lại!')),
          );
          return;
        }

        // Tạo đối tượng dữ liệu bài viết
        final postData = CreatePostObject(
          text: content,
          image: _imagePath, // Nếu có ảnh, sẽ gửi URL ảnh
          token: token,
        );

        // Gửi yêu cầu POST đến API
        final response = await CreatePostApi(apiClient: ApiClient()).createPost(postData);

        // Kiểm tra phản hồi từ API
        if (response != null) {
          // In thông báo kiểm tra nếu bài viết tạo thành công
          print('Bài viết đã được tạo thành công: $response');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bài viết đã được tạo')),
          );
          Navigator.pop(context); // Quay lại màn hình trước
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể tạo bài viết')),
          );
        }
      } catch (error) {
        print('Lỗi khi tạo bài viết: $error');
        // Xử lý lỗi khi tạo bài viết
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tạo bài viết: $error')),
        );
      }
    } else {
      // Thông báo nếu người dùng không nhập nội dung hoặc ảnh
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng cung cấp nội dung hoặc ảnh')),
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
