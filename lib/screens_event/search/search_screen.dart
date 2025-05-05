import 'package:flutter/material.dart';
import '../user/profile_screen.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/auth/auth_me_api.dart';
import 'package:kotlin/api/client/id_storage.dart';
import 'package:kotlin/api/client/search/search_api.dart';
import 'package:kotlin/api/dto/search/post_search_oj.dart';
import 'package:kotlin/api/dto/search/user_search_oj.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';

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
      if (postResults.isEmpty) return const Text("Không có bài viết", style: TextStyle(color: Colors.grey));
      return Expanded(
        child: ListView.separated(
          itemCount: postResults.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white10),
          itemBuilder: (context, index) {
            final post = postResults[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: post.image != null
                  ? Image.network(post.image!, width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.text_snippet, color: Colors.white),
              title: Text(post.text, style: const TextStyle(color: Colors.white)),
              subtitle: Text("Tác giả: ${post.authorName}", style: const TextStyle(color: Colors.grey)),
            );
          },
        ),
      );
    } else {
      if (userResults.isEmpty) return const Text("Không có người dùng", style: TextStyle(color: Colors.grey));
      return Expanded(
        child: ListView.separated(
          itemCount: userResults.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white10),
          itemBuilder: (context, index) {
            final user = userResults[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: user.profileImg != null
                  ? CircleAvatar(backgroundImage: NetworkImage(user.profileImg!))
                  : const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user.fullname, style: const TextStyle(color: Colors.white)),
              subtitle: Text(user.username ?? '', style: const TextStyle(color: Colors.grey)),
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
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: currentUser?.profileImg != null
                ? CircleAvatar(radius: 20, backgroundImage: NetworkImage(currentUser!.profileImg!))
                : CircleAvatar(
              radius: 20,
              backgroundColor: Colors.purple,
              child: Text(
                (currentUser?.fullname ?? currentUser?.username ?? 'U')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        title: const Text("Tìm kiếm", style: TextStyle(color: Colors.white)),
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
