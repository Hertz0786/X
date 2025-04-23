import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Để làm việc với File (ảnh)

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  File? _avatarImage;
  File? _coverImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAvatar() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _avatarImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _pickCoverImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _coverImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Chỉnh sửa hồ sơ", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Lưu thông tin chỉnh sửa
              print('Thông tin đã được lưu');
              Navigator.pop(context);
            },
            child: const Text("Lưu", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: SingleChildScrollView(  // Bọc tất cả trong SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bìa
            GestureDetector(
              onTap: _pickCoverImage,
              child: _coverImage == null
                  ? Container(
                height: 200,
                color: Colors.grey,
                child: const Center(child: Text("Chọn ảnh bìa", style: TextStyle(color: Colors.white))),
              )
                  : Image.file(
                _coverImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Avatar
            GestureDetector(
              onTap: _pickAvatar,
              child: _avatarImage == null
                  ? const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.purple,
                child: Icon(Icons.camera_alt, color: Colors.white),
              )
                  : CircleAvatar(
                radius: 60,
                backgroundImage: FileImage(_avatarImage!),
              ),
            ),
            const SizedBox(height: 16),

            // Tên người dùng
            const Text(
              "Tên:",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
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
            const Text(
              "Email:",
              style: TextStyle(color: Colors.white),
            ),
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

            // Số điện thoại
            const Text(
              "Số điện thoại:",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Nhập số điện thoại",
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

            // Tiểu sử
            const Text(
              "Tiểu sử:",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3, // Cho phép nhập nhiều dòng
              decoration: const InputDecoration(
                hintText: "Nhập tiểu sử của bạn",
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
