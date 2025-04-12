import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Tìm kiếm", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước
          },
        ),
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
                  _searchQuery = query; // Cập nhật từ khóa tìm kiếm
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

            // Hiển thị kết quả tìm kiếm (giả lập)
            if (_searchQuery.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: 10, // Số lượng kết quả tìm kiếm giả lập
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        'Kết quả tìm kiếm $index: $_searchQuery',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            if (_searchQuery.isEmpty)
              const Center(
                child: Text(
                  "Nhập từ khóa tìm kiếm...",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
