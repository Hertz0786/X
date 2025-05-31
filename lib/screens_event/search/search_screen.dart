import 'package:flutter/material.dart';
import '../user/profile_screen.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/auth/auth_me_api.dart';
import 'package:kotlin/api/client/id_storage.dart';
import 'package:kotlin/api/client/search/search_api.dart';
import 'package:kotlin/api/dto/search/post_search_oj.dart';
import 'package:kotlin/api/dto/search/user_search_oj.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';
import 'package:kotlin/api/client/user/get_user.dart';
import 'package:kotlin/screens_event/post/post_detail_screen.dart';
import 'package:kotlin/api/client/post/like_unlike_post_api.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/client/rp-ed/report_service.dart';
import 'package:kotlin/api/client/rp-ed/report_request_dto.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/dto/post/cm_oj.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  GetMeObject? currentUser;
  String? currentUserId;
  List<PostSearchResult> postResults = [];
  List<UserSearchResult> userResults = [];
  bool isLoading = false;
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    final id = await IdStorage.getUserId();
    final user = await AuthMeApi(apiClient: ApiClient()).fetchCurrentUser();
    setState(() {
      currentUserId = id;
      currentUser = user;
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      isLoading = true;
      postResults.clear();
      userResults.clear();
    });

    try {
      if (selectedTab == 0) {
        final posts = await PostApi().searchPosts(query);
        setState(() {
          postResults = posts.where((post) => post.id != currentUserId).toList();
        });
        await _fetchAuthorsForPosts(postResults);
      } else {
        final users = await UserApi().searchUsers(query);
        setState(() {
          userResults = users;
        });
      }
    } catch (e) {
      print("❌ Lỗi tìm kiếm: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchAuthorsForPosts(List<PostSearchResult> posts) async {
    final getUser = GetUser(apiClient: ApiClient());
    for (var post in posts) {
      await post.fetchAuthorName(getUser);
    }
    setState(() {});
  }

  void _showReportSheet(String postId) {
    final TextEditingController controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Lý do báo cáo bài viết",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng nhập lý do")),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  try {
                    await ReportService().reportPost(
                      postId: postId,
                      dto: ReportRequestDto(reason: reason),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã gửi báo cáo")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi: $e")),
                    );
                  }
                },
                child: const Text("Gửi báo cáo"),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabs() {
    final tabs = ['Bài viết', 'Người dùng'];
    return Row(
      children: List.generate(tabs.length, (i) {
        final isSelected = selectedTab == i;
        return GestureDetector(
          onTap: () => setState(() => selectedTab = i),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isSelected ? Colors.blue : Colors.grey[800],
            ),
            child: Text(
              tabs[i],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResults() {
    if (isLoading) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    if (selectedTab == 0) {
      if (postResults.isEmpty) {
        return const Text("Không có bài viết", style: TextStyle(color: Colors.grey));
      }

      return Expanded(
        child: ListView.separated(
          itemCount: postResults.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white10),
          itemBuilder: (context, index) {
            final post = postResults[index];
            final isLiked = post.likes.contains(currentUserId);

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PostDetailScreen(post: post.toCreatePostObject())),
                );
              },
              child: Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(
                              post.authorProfileImg?.isNotEmpty == true
                                  ? post.authorProfileImg!
                                  : "https://cryptologos.cc/logos/uniswap-uniswap-logo.png",
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Người đăng: ${post.authorName}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (post.text.isNotEmpty)
                        Text(
                          post.text,
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
                            onPressed: () async {
                              final token = await TokenStorage.getToken();
                              if (token != null && post.id != null) {
                                try {
                                  final updatedPost = await LikeUnlikePostApi(apiClient: ApiClient())
                                      .likeOrUnlikePost(postId: post.id!, token: token);
                                  setState(() {
                                    postResults[index] = updatedPost.toSearchResult(
                                      post.authorName,
                                      post.authorProfileImg,
                                    );
                                  });
                                } catch (e) {
                                  print("❌ Lỗi like/unlike: $e");
                                }
                              }
                            },
                          ),
                          Text("${post.likes.length} lượt thích",
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
    } else {
      if (userResults.isEmpty) {
        return const Text("Không có người dùng", style: TextStyle(color: Colors.grey));
      }

      return Expanded(
        child: ListView.separated(
          itemCount: userResults.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white10),
          itemBuilder: (context, index) {
            final user = userResults[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: user.id),
                  ),
                );
              },
              leading: (user.profileImg != null && user.profileImg!.isNotEmpty)
                  ? CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(user.profileImg!),
              )
                  : CircleAvatar(
                radius: 25,
                backgroundColor:
                (Colors.primaries[user.fullname.hashCode % Colors.primaries.length])
                    .shade700,
                child: Text(
                  (user.fullname.isNotEmpty ? user.fullname[0] : '?').toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(user.fullname, style: const TextStyle(color: Colors.white)),
              subtitle: Text(user.username ?? 'Không có tên người dùng',
                  style: const TextStyle(color: Colors.grey)),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProfileScreen(userId: currentUserId!)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: currentUser?.profileImg != null && currentUser!.profileImg!.isNotEmpty
                ? CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(currentUser!.profileImg!),
            )
                : CircleAvatar(
              radius: 22,
              backgroundColor: Colors.purple,
              child: Text(
                (currentUser?.fullname ?? currentUser?.username ?? 'U')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
              ),
            ),
          ),
        ),
        title: const Text("Tìm kiếm",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onSubmitted: _performSearch,
              decoration: InputDecoration(
                hintText: "Nhập từ khóa...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[800],
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => _performSearch(_searchController.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTabs(),
            const SizedBox(height: 12),
            _buildResults(),
          ],
        ),
      ),
    );
  }
}

extension CreatePostObjectExtensions on CreatePostObject {
  PostSearchResult toSearchResult(String? name, String? profileImg) {
    return PostSearchResult(
      id: id,
      userId: userId,
      text: text ?? '',
      image: image,
      authorName: name,
      authorProfileImg: profileImg,
      likes: likes ?? [],
      comments: comments ?? [],
    );
  }
}
