import 'package:flutter/material.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/post/delete_post_api.dart';
import 'package:kotlin/api/client/post/get_all_post_api.dart';
import 'package:kotlin/api/client/post/like_unlike_post_api.dart';
import 'package:kotlin/api/client/id_storage.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'post/post_detail_screen.dart';
import 'user/profile_screen.dart';

class XUI extends StatefulWidget {
  const XUI({super.key});
  static final GlobalKey<XUIState> xuiKey = GlobalKey<XUIState>();

  @override
  State<XUI> createState() => XUIState();
}

class XUIState extends State<XUI> {
  List<CreatePostObject> posts = [];
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
    fetchPosts();
  }

  Future<void> loadCurrentUser() async {
    final id = await IdStorage.getUserId();
    setState(() {
      currentUserId = id;
    });
  }

  Future<void> fetchPosts() async {
    try {
      final api = GetAllPostApi(apiClient: ApiClient());
      final data = await api.fetchPosts();
      setState(() {
        posts = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Lỗi khi lấy bài viết: $e");
    }
  }

  Future<void> _deletePost(String postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xoá"),
        content: const Text("Bạn có chắc muốn xoá bài viết này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Huỷ")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xoá")),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await DeletePostApi(apiClient: ApiClient()).deletePost(postId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xoá bài viết")),
      );
      await fetchPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xoá thất bại: $e")),
      );
    }
  }

  Future<void> _toggleLike(CreatePostObject post, int index) async {
    final token = await TokenStorage.getToken();
    if (token == null || post.id == null) return;

    try {
      final updatedPost = await LikeUnlikePostApi(apiClient: ApiClient())
          .likeOrUnlikePost(postId: post.id!, token: token);
      setState(() {
        posts[index] = updatedPost;
      });
    } catch (e) {
      print("Lỗi khi like/unlike: $e");
    }
  }

  String _formatDateTime(String dateTime) {
    final dt = DateTime.tryParse(dateTime);
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return "Vừa xong";
    if (diff.inMinutes < 60) return "${diff.inMinutes} phút trước";
    if (diff.inHours < 24) return "${diff.inHours} giờ trước";
    if (diff.inDays < 7) return "${diff.inDays} ngày trước";
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  bool _isLikedByCurrentUser(CreatePostObject post) {
    return post.likes?.contains(currentUserId) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.purple,
              child: Text("H", style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
        centerTitle: true,
        title: const Icon(Icons.close),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Dành cho bạn", style: TextStyle(color: Colors.white)),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Đang theo dõi", style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          final isLiked = _isLikedByCurrentUser(post);
          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
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
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage("https://cryptologos.cc/logos/uniswap-uniswap-logo.png"),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Người đăng: ${post.userId ?? 'Ẩn danh'}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        if (post.userId == currentUserId)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deletePost(post.id ?? ''),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (post.createdAt != null)
                      Text(
                        _formatDateTime(post.createdAt!),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    const SizedBox(height: 10),
                    if (post.text != null)
                      Text(
                        post.text!,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    if (post.image != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(post.image!),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.pinkAccent : Colors.white,
                          ),
                          onPressed: () => _toggleLike(post, index),
                        ),
                        Text(
                          "${post.likes?.length ?? 0} lượt thích",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
