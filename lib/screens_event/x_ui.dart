import 'package:flutter/material.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/post/delete_post_api.dart';
import 'package:kotlin/api/client/post/get_all_post_api.dart';
import 'package:kotlin/api/client/post/get_fl_post_api.dart';
import 'package:kotlin/api/client/post/like_unlike_post_api.dart';
import 'package:kotlin/api/client/id_storage.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/client/auth/auth_me_api.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';
import 'FollowButton.dart';
import 'post/post_detail_screen.dart';
import 'user/profile_screen.dart';
import 'package:kotlin/api/client/user/get_user.dart';

class XUI extends StatefulWidget {
  const XUI({super.key});
  static final GlobalKey<XUIState> xuiKey = GlobalKey<XUIState>();

  @override
  State<XUI> createState() => XUIState();
}

class XUIState extends State<XUI> with TickerProviderStateMixin {
  List<CreatePostObject> allPosts = [];
  List<CreatePostObject> followingPosts = [];
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
      setState(() {
        isLoading = true;
      });
      if (tabController.index == 0) {
        fetchAllPosts();
      } else {
        fetchFollowingPosts();
      }
    });
  }

  Future<void> loadData() async {
    final id = await IdStorage.getUserId();
    final user = await AuthMeApi(apiClient: ApiClient()).fetchCurrentUser();
    currentUserId = id;
    currentUser = user;
    followingIds = user.following ?? [];
    fetchAllPosts();
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
      tabController.index == 0 ? fetchAllPosts() : fetchFollowingPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xoá thất bại: $e")),
      );
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

  bool _isFollowing(String userId) {
    return followingIds.contains(userId);
  }

  void _updateFollowingList(String userId, bool isNowFollowing) {
    setState(() {
      if (isNowFollowing) {
        followingIds.add(userId);
      } else {
        followingIds.remove(userId);
      }
    });
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

  Widget _buildPostList(List<CreatePostObject> posts, bool isFollowTab) {
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Colors.black,
      onRefresh: () async {
        if (isFollowTab) {
          await fetchFollowingPosts();
        } else {
          await fetchAllPosts();
        }
      },
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
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
                        GestureDetector(
                          onTap: () async {
                            // Khi nhấn vào avatar, gọi API GetUser để lấy thông tin người dùng
                            try {
                              final user = await GetUser(apiClient: ApiClient())
                                  .fetchProfileById(post.userId!); // Lấy thông tin người dùng
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(userId: post.userId!),  // Truyền userId vào ProfileScreen
                                ),
                              );
                            } catch (e) {
                              print("Lỗi khi lấy thông tin người dùng: $e");
                            }
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
                          onPressed: () => _toggleLike(post, index, isFollowTab),
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
              padding: const EdgeInsets.all(8.0), // 👈 chỉnh cho bằng SearchScreen
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
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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