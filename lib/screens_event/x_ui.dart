import 'package:flutter/material.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/post/delete_post_api.dart';
import 'package:kotlin/api/client/post/get_all_post_api.dart';
import 'package:kotlin/api/client/post/get_fl_post_api.dart';
import 'package:kotlin/api/client/post/like_unlike_post_api.dart';
import 'package:kotlin/api/client/rp-ed/report_service.dart';
import 'package:kotlin/api/client/id_storage.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/client/auth/auth_me_api.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';
import 'package:kotlin/api/client/rp-ed/report_request_dto.dart';
import 'package:kotlin/api/client/user/get_user.dart';
import 'package:kotlin/api/client/user/gua.dart'; // import API mới
import 'package:kotlin/api/dto/user/u.dart';
import 'package:kotlin/screens_event/effect/color.dart';
import 'package:kotlin/screens_event/effect/hover.dart';
import 'FollowButton.dart';
import 'post/post_detail_screen.dart';
import 'user/profile_screen.dart';
import 'package:kotlin/screens_event/string_extension.dart';


class XUI extends StatefulWidget {
  const XUI({super.key});
  static final GlobalKey<XUIState> xuiKey = GlobalKey<XUIState>();

  @override
  State<XUI> createState() => XUIState();
}

class XUIState extends State<XUI> with TickerProviderStateMixin {
  List<CreatePostObject> allPosts = [];
  List<CreatePostObject> followingPosts = [];
  List<UserModel> suggestedUsers = [];
  bool isLoading = true;
  String? currentUserId;
  GetMeObject? currentUser;
  List<String> followingIds = [];
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    loadData();
    tabController.addListener(() {
      if (tabController.indexIsChanging) return;
      setState(() => isLoading = true);
      tabController.index == 0 ? fetchAllPosts() : fetchFollowingPosts();
    });
  }

  Future<void> loadData() async {
    final id = await IdStorage.getUserId();
    final user = await AuthMeApi(apiClient: ApiClient()).fetchCurrentUser();

    currentUserId = id;
    currentUser = user;
    followingIds = user.following ?? [];

    await Future.wait([fetchAllPosts(), _loadSuggestedUsers()]);
  }

  Future<void> fetchAllPosts() async {
    try {
      final data = await GetAllPostApi(apiClient: ApiClient()).fetchPosts();
      setState(() {
        allPosts = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Lỗi khi lấy bài viết: $e");
    }
  }

  Future<void> fetchFollowingPosts() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return;
      final data = await GetFollowingPostsApi(apiClient: ApiClient())
          .fetchFollowingPosts(token);
      setState(() {
        followingPosts = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Lỗi khi lấy bài viết đang theo dõi: $e");
    }
  }

  Future<void> _loadSuggestedUsers() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return;

      final users = await SuggestedUsersApi(apiClient: ApiClient())
          .getSuggestedUsers(token: token);

      print("👥 Số người được gợi ý: ${users.length}");
      users.forEach((u) => print("🔹 ${u.username} - ${u.id}"));

      setState(() => suggestedUsers = users);
    } catch (e) {
      print("❌ Lỗi khi lấy gợi ý người dùng: $e");
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Đã xoá bài viết")));
      tabController.index == 0 ? fetchAllPosts() : fetchFollowingPosts();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Xoá thất bại: $e")));
    }
  }

  Future<void> _toggleLike(CreatePostObject post, int index, bool isFollowTab) async {
    final token = await TokenStorage.getToken();
    if (token == null || post.id == null) return;
    try {
      final updatedPost = await LikeUnlikePostApi(apiClient: ApiClient())
          .likeOrUnlikePost(postId: post.id!, token: token);
      setState(() {
        if (isFollowTab) {
          followingPosts[index] = updatedPost.copyWith(
            username: post.username,
            fullname: post.fullname,
            profileImg: post.profileImg,
          );
        } else {
          allPosts[index] = updatedPost.copyWith(
            username: post.username,
            fullname: post.fullname,
            profileImg: post.profileImg,
          );
        }
      });
    } catch (e) {
      print("Lỗi khi like/unlike: $e");
    }
  }

  void _showReportSheet(String postId) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("Lý do báo cáo bài viết",
              style: TextStyle(fontSize: 16, color: Colors.white)),
          const SizedBox(height: 12),
          TextField(controller: controller, maxLines: 4, style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Nhập lý do...",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[850],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final reason = controller.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Vui lòng nhập lý do")));
                return;
              }
              Navigator.pop(context);
              try {
                await ReportService().reportPost(
                  postId: postId,
                  dto: ReportRequestDto(reason: reason),
                );
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Đã gửi báo cáo")));
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Lỗi: $e")));
              }
            },
            child: const Text("Gửi báo cáo"),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  bool _isFollowing(String userId) => followingIds.contains(userId);

  void _updateFollowingList(String userId, bool isNowFollowing) {
    setState(() {
      if (isNowFollowing) followingIds.add(userId);
      else followingIds.remove(userId);
    });
  }

  bool _isLikedByCurrentUser(CreatePostObject post) =>
      post.likes?.contains(currentUserId) ?? false;

  String _formatDateTime(String dateTime) {
    final dt = DateTime.tryParse(dateTime);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return "Vừa xong";
    if (diff.inMinutes < 60) return "${diff.inMinutes} phút trước";
    if (diff.inHours < 24) return "${diff.inHours} giờ trước";
    if (diff.inDays < 7) return "${diff.inDays} ngày trước";
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  Widget _buildSuggestedUsersWidget() {
    if (suggestedUsers.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 0, 8),
          child: Text(
            "Gợi ý cho bạn",
            style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: suggestedUsers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, idx) {
              final user = suggestedUsers[idx];
              final isFollowing = followingIds.contains(user.id);
              final name = (user.fullname?.trim().isNotEmpty == true ? user.fullname! : user.username).capitalize();

              return HoverCard(
                child: Container(
                  width: 180,
                  height: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0,3))],
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(userId: user.id),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: user.profileImg?.isNotEmpty == true
                              ? Colors.transparent
                              : getAvatarColor(user.id),
                          backgroundImage: user.profileImg?.isNotEmpty == true
                              ? NetworkImage(user.profileImg!)
                              : null,
                          child: user.profileImg?.isNotEmpty != true
                              ? Text(name[0], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isFollowing ? Colors.grey : Colors.blueAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => setState(() {
                          isFollowing ? followingIds.remove(user.id) : followingIds.add(user.id);
                        }),
                        child: Text(isFollowing ? "Đang theo dõi" : "Theo dõi",
                            style: TextStyle(color: isFollowing ? Colors.grey : Colors.blueAccent)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }




  Widget _buildPostList(List<CreatePostObject> posts, bool isFollowTab) {
    final showSuggestions = !isFollowTab && suggestedUsers.isNotEmpty;
    final insertIndex = (posts.length >= 5) ? 5 : posts.length;

    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Colors.black,
      onRefresh: () async {
        isFollowTab ? fetchFollowingPosts() : fetchAllPosts();
      },
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: posts.length + (showSuggestions ? 1 : 0),
        itemBuilder: (context, index) {
          if (showSuggestions && index == insertIndex) {
            return _buildSuggestedUsersWidget();
          }

          final isAfterInsert = showSuggestions && index > insertIndex;
          final postIndex = isAfterInsert ? index - 1 : index;

          if (postIndex >= posts.length) return const SizedBox();

          final post = posts[postIndex];
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
                  MaterialPageRoute(
                      builder: (_) => PostDetailScreen(post: post)),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // avatar + tên + follow + delete
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfileScreen(userId: post.userId!),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: post.profileImg != null
                                ? NetworkImage(post.profileImg!)
                                : const NetworkImage("https://cryptologos.cc/logos/uniswap-uniswap-logo.png"),
                          ),
                        ),

                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Người đăng: ${post.fullname ?? post.username ?? post.userId}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        post.userId == currentUserId
                            ? IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deletePost(post.id ?? ''),
                        )
                            : FollowButton(
                          targetUserId: post.userId!,
                          isInitiallyFollowing: _isFollowing(post.userId!),
                          onChanged: (isNowFollowing) {
                            _updateFollowingList(post.userId!, isNowFollowing);
                          },
                        ),
                      ],
                    ),
                    if (post.createdAt != null)
                      Text(_formatDateTime(post.createdAt!),
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    if (post.text != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(post.text!,
                            style: const TextStyle(color: Colors.white)),
                      ),
                    if (post.image != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(post.image!),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.pinkAccent : Colors.white,
                          ),
                          onPressed: () => _toggleLike(post, postIndex, isFollowTab),
                        ),
                        Text("${post.likes?.length ?? 0} lượt thích",
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(width: 16),
                        const Icon(Icons.comment, color: Colors.blueAccent, size: 20),
                        const SizedBox(width: 4),
                        Text("${post.comments.length} bình luận",
                            style: const TextStyle(color: Colors.white70)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.flag, color: Colors.amber),
                          onPressed: () => _showReportSheet(post.id ?? ''),
                          tooltip: "Báo cáo bài viết",
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



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              if (currentUserId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: currentUserId!),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: currentUser?.profileImg != null && currentUser!.profileImg!.isNotEmpty
                  ? CircleAvatar(radius: 22, backgroundImage: NetworkImage(currentUser!.profileImg!))
                  : CircleAvatar(
                radius: 22,
                backgroundColor: Colors.purple,
                child: Text(
                  (currentUser?.fullname ?? currentUser?.username ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          centerTitle: true,
          title: const Text(
            'X',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          bottom: TabBar(
            controller: tabController,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Dành cho bạn'),
              Tab(text: 'Đang theo dõi'),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            _buildPostList(allPosts, false),
            _buildPostList(followingPosts, true),
          ],
        ),
      ),
    );
  }
}
