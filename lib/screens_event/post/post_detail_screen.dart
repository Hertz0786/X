import 'package:flutter/material.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/post/comment_on_post_api.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/dto/post/comment_on_post_oj.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/dto/post/cm_oj.dart';

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
                    post.profileImg ??
                        "https://cryptologos.cc/logos/uniswap-uniswap-logo.png",
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
                return ListTile(
                  title: Text(cmt.text,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text("Người dùng: ${cmt.user}",
                      style:
                      const TextStyle(color: Colors.grey)),
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
