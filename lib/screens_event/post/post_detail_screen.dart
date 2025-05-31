import 'package:flutter/material.dart';
import 'dart:math';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/post/comment_on_post_api.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/dto/post/comment_on_post_oj.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/dto/post/cm_oj.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';
import 'package:kotlin/api/client/user/get_user.dart';

class PostDetailScreen extends StatefulWidget {
  final CreatePostObject post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoadingComments = false;
  List<CMObject> _comments = [];
  final Map<String, GetMeObject> _userProfiles = {};

  final List<Color> _avatarColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  Color _getRandomColorExcludingBlack() {
    final random = Random();
    return _avatarColors[random.nextInt(_avatarColors.length)];
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    final token = await TokenStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để bình luận')),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final comment = CommentOnPostObject(
      idpost: widget.post.id ?? '',
      text: text,
      token: token,
    );

    final commentService = CommentService(ApiClient());

    try {
      final updatedPost = await commentService.commentOnPost(comment);
      setState(() {
        _comments = updatedPost.comments;
        _commentController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gửi bình luận: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<GetMeObject?> _getUserProfile(String userId) async {
    if (_userProfiles.containsKey(userId)) {
      return _userProfiles[userId];
    }

    try {
      final userService = GetUser(apiClient: ApiClient());
      final profile = await userService.fetchProfileById(userId);
      setState(() {
        _userProfiles[userId] = profile;
      });
      return profile;
    } catch (e) {
      debugPrint("Lỗi khi lấy thông tin user: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _comments = widget.post.comments;
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Bài viết", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                    post.profileImg?.isNotEmpty == true
                        ? post.profileImg!
                        : "https://via.placeholder.com/150",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.fullname ?? post.username ?? "Người dùng",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post.text ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      if (post.image != null) ...[
                        const SizedBox(height: 8),
                        Image.network(post.image!)
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Bình luận",
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          Expanded(
            child: _isLoadingComments
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                ? const Center(
                child: Text("Chưa có bình luận nào",
                    style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final cmt = _comments[index];
                return FutureBuilder<GetMeObject?>(
                  future: cmt.user != null
                      ? _getUserProfile(cmt.user!)
                      : Future.value(null),
                  builder: (context, snapshot) {
                    final user = snapshot.data;
                    final avatarUrl = user?.profileImg;
                    final fullName =
                        user?.fullname ?? user?.username ?? "Ẩn danh";
                    final firstLetter = fullName.isNotEmpty
                        ? fullName[0].toUpperCase()
                        : '?';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (avatarUrl != null &&
                            avatarUrl.isNotEmpty)
                            ? NetworkImage(avatarUrl)
                            : null,
                        backgroundColor: (avatarUrl == null ||
                            avatarUrl.isEmpty)
                            ? _getRandomColorExcludingBlack()
                            : Colors.transparent,
                        child: (avatarUrl == null ||
                            avatarUrl.isEmpty)
                            ? Text(firstLetter,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))
                            : null,
                      ),
                      title: Text(cmt.text,
                          style:
                          const TextStyle(color: Colors.white)),
                      subtitle: Text("Người dùng: $fullName",
                          style:
                          const TextStyle(color: Colors.grey)),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.black,
              border: Border(top: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Viết bình luận...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: _isSubmitting
                      ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send, color: Colors.blue),
                  onPressed: _isSubmitting ? null : _submitComment,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
