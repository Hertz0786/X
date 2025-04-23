import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int selectedTab = 0;
  final List<String> tabs = ["Tất cả", "Đề cập", "Đã xác nhận"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.purple,
            child: Text('H'),
          ),
        ),
        title: const Text("Thông báo", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final isSelected = selectedTab == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedTab = index),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tabs[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            height: 2,
                            width: 30,
                            color: Colors.blue,
                          )
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(color: Colors.grey),
          // Nội dung chính
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bật thông báo đẩy',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Phát hiện khi bạn có hoạt động mới cần xem.',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: null,
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.white),
                  ),
                  child: Text('Nhận thông báo', style: TextStyle(color: Colors.black)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
