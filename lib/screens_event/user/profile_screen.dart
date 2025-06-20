import 'package:flutter/material.dart';
import 'package:kotlin/api/client/auth/auth_me_api.dart';
import 'package:kotlin/api/client/id_storage.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/client/post/get_user_post.dart';
import 'package:kotlin/api/client/user/get_user.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/client/user/follow_unfl_user_api.dart';
import 'package:kotlin/screens_event/post/post_detail_screen.dart';
import 'edit_profile_screen.dart';
import 'liked_post_screen.dart';
import 'package:kotlin/screens_event/string_extension.dart';
import '../FollowButton.dart';
import 'package:kotlin/api/client/api_client.dart';

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
  bool isFollowing = false;

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
      final apiClient = AuthMeApi(apiClient: ApiClient());
      final isMe = widget.userId == currentUserId;
      final fetchedUser = isMe
          ? await apiClient.fetchCurrentUser()
          : await GetUser(apiClient: ApiClient()).fetchProfileById(widget.userId);

      final token = await TokenStorage.getToken() ?? '';
      final posts = await PostService(ApiClient()).getUserPosts(fetchedUser.username, token: token);

      setState(() {
        user = fetchedUser;
        userPosts = posts;
        isFollowing = !isMe && (fetchedUser.followers?.contains(currentUserId) ?? false);
        isLoading = false;
      });
    } catch (e) {
      print("❌ Lỗi tải profile: $e");
      setState(() => isLoading = false);
    }
  }

  int _countLikedPosts() {
    return userPosts.where((p) => p.likes?.contains(currentUserId) ?? false).length;
  }

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
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PostDetailScreen(post: post))),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.text != null)
                    Text(post.text!, style: const TextStyle(color: Colors.white)),
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

  Widget _buildStat(String label, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$count", style: const TextStyle(color: Colors.white, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.userId == currentUserId;
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
          ? const Center(child: Text("Không thể tải dữ liệu", style: TextStyle(color: Colors.white)))
          : SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 220,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[800],
                  child: user!.coverImg?.isNotEmpty == true
                      ? Image.network(user!.coverImg!, fit: BoxFit.cover)
                      : null,
                ),
                Positioned(
                  bottom: -40,
                  left: 16,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: user!.profileImg?.isNotEmpty == true
                        ? NetworkImage(user!.profileImg!)
                        : null,
                    child: (user!.profileImg?.isEmpty ?? true)
                        ? Text(
                      user!.username[0].toUpperCase(),
                      style: const TextStyle(fontSize: 30, color: Colors.black),
                    )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: -20,
                  right: 16,
                  child: isMe
                      ? ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text("Chỉnh sửa", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  )
                      : FollowButton(
                    targetUserId: widget.userId,
                    isInitiallyFollowing: isFollowing,
                    onChanged: (followed) => setState(() => isFollowing = followed),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user!.fullname ?? user!.username,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("@${user!.username}", style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Row(children: [
                _buildStat("Bài viết", userPosts.length),
                const SizedBox(width: 24),
                _buildStat("Đã thích", _countLikedPosts()),
              ]),
            ]),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Thông tin liên lạc:",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Email: ${user!.email}", style: const TextStyle(color: Colors.grey)),
              if (user!.bio?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text("Bio: ${user!.bio}", style: const TextStyle(color: Colors.grey)),
              ],
            ]),
          ),
          const SizedBox(height: 30),
          if (isMe)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const LikedPostsScreen())),
                icon: const Icon(Icons.favorite, color: Colors.white),
                label: const Text("Bài viết đã thích", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              ),
            ),
          const SizedBox(height: 20),
          _buildPostList(),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}
