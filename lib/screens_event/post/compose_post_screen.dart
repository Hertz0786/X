import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/client/post/create_post_api.dart';

class ComposePostScreen extends StatefulWidget {
  const ComposePostScreen({super.key});

  @override
  State<ComposePostScreen> createState() => _ComposePostScreenState();
}

class _ComposePostScreenState extends State<ComposePostScreen> {
  final TextEditingController _controller = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _submitPost() async {
    final content = _controller.text.trim();
    final token = await TokenStorage.getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn cần đăng nhập")),
      );
      return;
    }

    if (content.isEmpty && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung hoặc chọn ảnh')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? base64Image;
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}'; // ✅ Thêm prefix
      }

      final post = CreatePostObject(
        text: content,
        image: base64Image,
        token: token,
      );

      print("📤 POST BODY: ${post.toJson()}");

      final response = await CreatePostApi(apiClient: ApiClient()).createPost(post);

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bài viết đã được tạo')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tạo bài viết')),
        );
      }
    } catch (e, stack) {
      print("❌ Lỗi khi tạo bài viết: $e");
      print("📛 StackTrace: $stack");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
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
            onPressed: _isSubmitting ? null : _submitPost,
            child: Text("Đăng", style: TextStyle(color: _isSubmitting ? Colors.grey : Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: null,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Bạn đang nghĩ gì?",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),
            if (_imageFile != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_imageFile!, height: 180, fit: BoxFit.cover),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => _imageFile = null),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo),
              label: const Text("Chọn ảnh"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
