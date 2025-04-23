import 'package:flutter/material.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/client/post/comment_on_post_api.dart';

class PostDetailScreen extends StatefulWidget {
  final CreatePostObject post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      await CommentOnPostApi(apiClient: ApiClient()).commentOnPost(
        postId: widget.post.id!,
        text: text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bình luận đã được gửi")),
      );

      _commentController.clear();
      // TODO: Load lại danh sách bình luận nếu có
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
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
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                "https://cryptologos.cc/logos/uniswap-uniswap-logo.png",
              ),
            ),
            title: Text(post.text ?? '', style: const TextStyle(color: Colors.white)),
            subtitle: post.image != null
                ? Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Image.network(post.image!),
            )
                : null,
          ),
          const Divider(color: Colors.grey),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Bình luận", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          const Expanded(
            child: Center(
              child: Text("Chưa có dữ liệu bình luận",
                  style: TextStyle(color: Colors.grey)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
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
