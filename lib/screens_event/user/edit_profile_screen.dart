import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert'; // For base64 encoding
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/auth/auth_me_api.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); // Temporary TextField
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
        _avatarBase64 = base64Encode(bytes);
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
        _coverBase64 = base64Encode(bytes);
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
    try {
      final Map<String, dynamic> updatedData = {
        'fullname': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'bio': _bioController.text.trim(),
        'profileImg': _avatarBase64,
        'coverImg': _coverBase64,
      };

      // TODO: Implement the API call to update the user profile with updatedData

      print("Profile updated successfully.");
    } catch (e) {
      print("Error saving profile: $e");
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
            // Cover Image
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
            // Avatar
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
