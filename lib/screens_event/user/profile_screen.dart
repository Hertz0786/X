import 'package:flutter/material.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';
import 'package:kotlin/api/client/auth/auth_me_api.dart';
import 'package:kotlin/api/client/user/get_user.dart';
import 'package:kotlin/api/client/id_storage.dart';
import 'edit_profile_screen.dart';
import 'liked_post_screen.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/client/post/get_user_post.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/screens_event/post/post_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GetMeObject? user;
  bool isLoading = true;
  String? currentUserId;
  List<CreatePostObject> userPosts = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    currentUserId = await IdStorage.getUserId();
    await _fetchUserAndPosts();
  }

  Future<void> _fetchUserAndPosts() async {
    setState(() {
      isLoading = true;
      userPosts = [];
    });

    try {
      final isMe = widget.userId == currentUserId;
      final apiClient = ApiClient();

      final fetchedUser = isMe
          ? await AuthMeApi(apiClient: apiClient).fetchCurrentUser()
          : await GetUser(apiClient: apiClient).fetchProfileById(widget.userId);

      final token = await TokenStorage.getToken();
      if (token == null) throw Exception("Token không tồn tại");

      final postService = PostService(apiClient);
      final posts = await postService.getUserPosts(fetchedUser.username, token: token);

      setState(() {
        user = fetchedUser;
        userPosts = posts;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi tải hồ sơ: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Hiển thị danh sách bài viết
  Widget _buildPostList() {
    if (userPosts.isEmpty) {
      return const Center(child: Text("Chưa có bài viết", style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: userPosts.length,
      itemBuilder: (context, index) {
        final post = userPosts[index];
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.text ?? "", style: const TextStyle(color: Colors.white)),
                  if (post.image != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(post.image!),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Hồ sơ", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? const Center(child: Text("Không thể tải thông tin người dùng", style: TextStyle(color: Colors.white)))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bìa + avatar + nút chỉnh sửa
            SizedBox(
              height: 220,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Ảnh bìa
                  if (user!.coverImg != null && user!.coverImg!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Image.network(
                        user!.coverImg!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey[800],
                    ),

                  // Avatar
                  Positioned(
                    bottom: -40,
                    left: 16,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: (user!.profileImg != null && user!.profileImg!.isNotEmpty)
                          ? NetworkImage(user!.profileImg!)
                          : null,
                      child: (user!.profileImg == null || user!.profileImg!.isEmpty)
                          ? Text(
                        user!.username[0].toUpperCase(),
                        style: const TextStyle(color: Colors.black, fontSize: 30),
                      )
                          : null,
                    ),
                  ),

                  // Nút chỉnh sửa
                  if (widget.userId == currentUserId)
                    Positioned(
                      bottom: -20,
                      right: 16,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          );
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text("Chỉnh sửa", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 60),

            // Tên + username + thống kê
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user!.fullname ?? user!.username,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("@${user!.username}", style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStat("Bài viết", userPosts.length),
                      const SizedBox(width: 24),
                      _buildStat("Đã thích", 0),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Thông tin liên lạc
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Thông tin liên lạc:",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Email: ${user!.email}", style: const TextStyle(color: Colors.grey)),
                  if (user!.bio != null && user!.bio!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text("Bio: ${user!.bio}", style: const TextStyle(color: Colors.grey)),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),

            if (widget.userId == currentUserId)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LikedPostsScreen()),
                    );
                  },
                  icon: const Icon(Icons.favorite, color: Colors.white),
                  label: const Text("Bài viết đã thích", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),

            const SizedBox(height: 20),
            _buildPostList(),
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$count", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.normal)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }
}
