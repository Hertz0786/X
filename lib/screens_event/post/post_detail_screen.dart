import 'package:flutter/material.dart';
import 'dart:math';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/post/comment_on_post_api.dart';
import 'package:kotlin/api/client/post/like_unlike_post_api.dart';
import 'package:kotlin/api/client/rp-ed/report_service.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/client/user/get_user.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/dto/post/comment_on_post_oj.dart';
import 'package:kotlin/api/dto/post/cm_oj.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';
import 'package:kotlin/api/client/rp-ed/report_request_dto.dart';

class PostDetailScreen extends StatefulWidget {
  final CreatePostObject? post;
  final String? postId;

  const PostDetailScreen({super.key, this.post, this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoadingComments = false;
  List<CMObject> _comments = [];
  final Map<String, GetMeObject> _userProfiles = {};
  CreatePostObject? _currentPost;

  final List<Color> _avatarColors = [
    Colors.red, Colors.green, Colors.blue, Colors.orange,
    Colors.purple, Colors.teal, Colors.indigo, Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _currentPost = widget.post!;
      _comments = _currentPost!.comments;
    } else if (widget.postId != null) {
      _fetchPostById(widget.postId!);
    }
  }

  Future<void> _fetchPostById(String postId) async {
    setState(() => _isLoadingComments = true);
    try {
      final post = await GetUser(apiClient: ApiClient()).fetchPostById(postId);
      setState(() {
        _currentPost = post;
        _comments = post.comments;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không tìm được bài viết: $e")),
      );
    } finally {
      setState(() => _isLoadingComments = false);
    }
  }

  Color _getRandomColorExcludingBlack() {
    final random = Random();
    return _avatarColors[random.nextInt(_avatarColors.length)];
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _currentPost?.id == null) return;

    setState(() => _isSubmitting = true);

    final token = await TokenStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để bình luận')),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final comment = CommentOnPostObject(
      idpost: _currentPost!.id!,
      text: text,
      token: token,
    );

    try {
      final updatedPost = await CommentService(ApiClient()).commentOnPost(comment);
      setState(() {
        _comments = updatedPost.comments;
        _currentPost = _currentPost!.copyWith(comments: updatedPost.comments);
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

  Future<void> _toggleLike() async {
    final token = await TokenStorage.getToken();
    if (token == null || _currentPost?.id == null) return;

    try {
      final updatedPost = await LikeUnlikePostApi(apiClient: ApiClient())
          .likeOrUnlikePost(postId: _currentPost!.id!, token: token);
      setState(() {
        _currentPost = _currentPost!.copyWith(
          likes: updatedPost.likes,
          comments: updatedPost.comments,
        );
      });
    } catch (e) {
      debugPrint("Lỗi khi like/unlike: $e");
    }
  }

  Future<void> _showReportDialog({required String targetId, required bool isPost}) async {
    final TextEditingController _reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Báo cáo ${isPost ? 'bài viết' : 'bình luận'}'),
        content: TextField(
          controller: _reasonController,
          decoration: const InputDecoration(hintText: 'Nhập lý do báo cáo'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              final reason = _reasonController.text.trim();
              if (reason.isEmpty) return;

              final dto = ReportRequestDto(reason: reason);
              try {
                final reportService = ReportService();
                if (isPost) {
                  await reportService.reportPost(postId: targetId, dto: dto);
                } else {
                  await reportService.reportComment(commentId: targetId, dto: dto);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã gửi báo cáo thành công")),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi khi gửi báo cáo: $e")),
                );
              }
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  Future<GetMeObject?> _getUserProfile(String userId) async {
    if (_userProfiles.containsKey(userId)) return _userProfiles[userId];

    try {
      final profile = await GetUser(apiClient: ApiClient()).fetchProfileById(userId);
      setState(() => _userProfiles[userId] = profile);
      return profile;
    } catch (e) {
      debugPrint("Lỗi khi lấy thông tin user: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingComments || _currentPost == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final post = _currentPost!;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: (post.profileImg?.isNotEmpty == true)
                          ? NetworkImage(post.profileImg!)
                          : null,
                      backgroundColor: (post.profileImg == null || post.profileImg!.isEmpty)
                          ? Colors.grey
                          : Colors.transparent,
                      child: (post.profileImg == null || post.profileImg!.isEmpty)
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      post.fullname ?? post.username ?? 'Người dùng',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (post.text != null)
                  Text(post.text!, style: const TextStyle(color: Colors.white)),
                if (post.image != null && post.image!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Image.network(post.image!)
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        post.likes?.contains(post.userId) == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.pinkAccent,
                      ),
                      onPressed: _toggleLike,
                    ),
                    Text(
                      '${post.likes?.length ?? 0} lượt thích',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.comment, color: Colors.blueAccent, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${_comments.length} bình luận',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.flag, color: Colors.red),
                      tooltip: 'Báo cáo bài viết',
                      onPressed: () => _showReportDialog(targetId: post.id ?? '', isPost: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey),
          Expanded(
            child: _comments.isEmpty
                ? const Center(child: Text("Chưa có bình luận nào", style: TextStyle(color: Colors.grey)))
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
                    final fullName = user?.fullname ?? user?.username ?? "Ẩn danh";
                    final avatar = user?.profileImg;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: avatar != null && avatar.isNotEmpty
                            ? NetworkImage(avatar)
                            : null,
                        backgroundColor: avatar == null || avatar.isEmpty
                            ? _getRandomColorExcludingBlack()
                            : Colors.transparent,
                        child: avatar == null || avatar.isEmpty
                            ? Text(fullName[0].toUpperCase(), style: const TextStyle(color: Colors.white))
                            : null,
                      ),
                      title: Text(cmt.text, style: const TextStyle(color: Colors.white)),
                      subtitle: Text("Người dùng: $fullName", style: const TextStyle(color: Colors.grey)),
                      trailing: IconButton(
                        icon: const Icon(Icons.flag, color: Colors.redAccent),
                        onPressed: () => _showReportDialog(
                          targetId: cmt.id,
                          isPost: false,
                        ),
                      ),
                    );
                  },
                );
              },
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
          ),
        ],
      ),
    );
  }
}
