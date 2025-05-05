import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/auth/auth_me_api.dart';
import 'package:kotlin/api/dto/user/update_user_profile_oj.dart';
import 'package:kotlin/api/client/user/update_user_profile_api.dart';
import 'package:kotlin/api/client/token_storage.dart';

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

  String? _avatarUrl;
  String? _coverUrl;

  String? _avatarBase64;
  String? _coverBase64;

  bool isLoading = true;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAvatar() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final bytes = await File(pickedImage.path).readAsBytes();
      setState(() {
        _avatarImage = File(pickedImage.path);
        _avatarBase64 = 'data:image/jpeg;base64,' + base64Encode(bytes); // ✅ Thêm tiền tố
        _avatarUrl = null;
      });
    }
  }

  Future<void> _pickCoverImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final bytes = await File(pickedImage.path).readAsBytes();
      setState(() {
        _coverImage = File(pickedImage.path);
        _coverBase64 = 'data:image/jpeg;base64,' + base64Encode(bytes); // ✅ Thêm tiền tố
        _coverUrl = null;
      });
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await AuthMeApi(apiClient: ApiClient()).fetchCurrentUser();
      _nameController.text = user.fullname ?? '';
      _emailController.text = user.email;
      _bioController.text = user.bio ?? '';
      _avatarUrl = user.profileImg;
      _coverUrl = user.coverImg;
    } catch (e) {
      print("Error loading user info: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    print("🔄 Save button pressed");

    try {
      final token = await TokenStorage.getToken();
      print("📦 Token: $token");

      final request = UserProfileUpdateRequest(
        fullname: _nameController.text.trim(),
        email: _emailController.text.trim(),
        bio: _bioController.text.trim(),
        profileImg: _avatarBase64,
        coverImg: _coverBase64,
      );

      print("📤 Sending data: ${request.toJson()}");

      final response = await UserRepository().updateUserProfile(request, token: token);

      print("✅ Server Response:");
      print("🟢 Message: ${response['message']}");
      print("👤 User: ${response['user']}");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Updated successfully')),
        );
      }
    } catch (e, stackTrace) {
      print("❌ Error saving profile: $e");
      print("🪵 StackTrace: $stackTrace");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to update profile: $e')),
        );
      }
    }
  }


  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text("Save", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickCoverImage,
              child: _coverImage != null
                  ? Image.file(_coverImage!, height: 200, fit: BoxFit.cover, width: double.infinity)
                  : (_coverUrl != null
                  ? Image.network(_coverUrl!, height: 200, fit: BoxFit.cover, width: double.infinity)
                  : Container(
                height: 200,
                color: Colors.grey,
                child: const Center(child: Text("Select Cover Image", style: TextStyle(color: Colors.white))),
              )),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: _avatarImage != null
                    ? CircleAvatar(radius: 60, backgroundImage: FileImage(_avatarImage!))
                    : (_avatarUrl != null
                    ? CircleAvatar(radius: 60, backgroundImage: NetworkImage(_avatarUrl!))
                    : const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                )),
              ),
            ),
            const SizedBox(height: 24),
            _buildField("Name:", _nameController, "Enter your name"),
            _buildField("Email:", _emailController, "Enter your email"),
            _buildField("Phone:", _phoneController, "Enter your phone number"),
            _buildField("Bio:", _bioController, "Enter your bio", lines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: lines,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
