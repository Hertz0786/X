import 'package:flutter/material.dart';
import '../user/profile_screen.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/auth/auth_me_api.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  GetMeObject? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthMeApi(apiClient: ApiClient()).fetchCurrentUser();
    setState(() {
      currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: currentUser?.profileImg != null && currentUser!.profileImg!.isNotEmpty
                ? CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(currentUser!.profileImg!),
            )
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Chức năng tìm kiếm nâng cao!")),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.search),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nhập từ khóa tìm kiếm:",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              decoration: const InputDecoration(
                hintText: "Tìm kiếm...",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _searchQuery.isNotEmpty
                  ? ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.search, color: Colors.white),
                    title: Text(
                      'Kết quả $index cho: $_searchQuery',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              )
                  : const Center(
                child: Text(
                  "Nhập từ khóa để tìm kiếm...",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
