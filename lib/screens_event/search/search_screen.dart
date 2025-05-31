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
                  backgroundColor: (Colors.primaries[user.fullname.hashCode % Colors.primaries.length]).shade700,
                  child: Text(
                    (user.fullname.isNotEmpty ? user.fullname[0] : '?').toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                radius: 22, // ✅ đồng bộ với NotificationScreen
                backgroundImage: NetworkImage(currentUser!.profileImg!),
              )
                  : CircleAvatar(
                radius: 22, // ✅ dùng chung kích thước
                backgroundColor: Colors.purple,
                child: Text(
                  (currentUser?.fullname ?? currentUser?.username ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ),

          title: const Text("Tìm kiếm", style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold)),
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
