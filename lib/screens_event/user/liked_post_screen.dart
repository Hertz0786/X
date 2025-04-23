import 'package:flutter/material.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/post/get_liked_post_api.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/screens_event/post/post_detail_screen.dart';

class LikedPostsScreen extends StatefulWidget {
  const LikedPostsScreen({super.key});

  @override
  State<LikedPostsScreen> createState() => _LikedPostsScreenState();
}

class _LikedPostsScreenState extends State<LikedPostsScreen> {
  List<CreatePostObject> likedPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLikedPosts();
  }

  Future<void> fetchLikedPosts() async {
    try {
      final api = GetLikedPostApi(apiClient: ApiClient());
      final posts = await api.fetchLikedPosts();
      setState(() {
        likedPosts = posts;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Lỗi khi lấy bài viết đã thích: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Bài viết đã thích", style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : likedPosts.isEmpty
          ? const Center(child: Text("Chưa thích bài viết nào", style: TextStyle(color: Colors.white70)))
          : ListView.builder(
        itemCount: likedPosts.length,
        itemBuilder: (context, index) {
          final post = likedPosts[index];
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
                          backgroundImage: NetworkImage(
                              "https://cryptologos.cc/logos/uniswap-uniswap-logo.png"),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Người đăng: ${post.userId ?? 'Ẩn danh'}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (post.text != null)
                      Text(post.text!,
                          style: const TextStyle(color: Colors.white, fontSize: 16)),
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
                        const Icon(Icons.favorite, color: Colors.pinkAccent),
                        const SizedBox(width: 5),
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
