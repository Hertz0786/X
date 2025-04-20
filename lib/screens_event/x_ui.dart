import 'package:flutter/material.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/post/get_all_post_api.dart';
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

  @override
  void initState() {
    super.initState();
    fetchPosts();
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
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostDetailScreen(post: post),
                ),
              );
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              leading: const CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(
                    "https://cryptologos.cc/logos/uniswap-uniswap-logo.png"),
              ),
              title: Text(
                post.text ?? '',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: post.image != null
                  ? Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(post.image!),
                ),
              )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
