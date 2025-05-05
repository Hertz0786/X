import 'package:flutter/material.dart';
import '../user/profile_screen.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/auth/auth_me_api.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';
import 'package:kotlin/api/client/id_storage.dart';
import 'package:kotlin/api/client/notification/notification_api.dart';
import 'package:kotlin/api/dto/notification/notification_oj.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int selectedTab = 0;
  final List<String> tabs = ["Tất cả", "Đề cập", "Đã xác nhận"];
  GetMeObject? currentUser;
  String? currentUserId;
  bool isLoading = true;
  List<NotificationModel> notifications = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => isLoading = true);
    final id = await IdStorage.getUserId();
    final user = await AuthMeApi(apiClient: ApiClient()).fetchCurrentUser();
    final fetched = await NotificationApi().getNotifications();

    setState(() {
      currentUserId = id;
      currentUser = user;
      notifications = fetched;
      isLoading = false;
    });
  }

  Future<void> _confirmDeleteAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc muốn xoá tất cả thông báo?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Huỷ")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xoá")),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await NotificationApi().deleteAllNotifications();
        setState(() => notifications.clear());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đã xoá tất cả thông báo")),
          );
        }
      } catch (e) {
        print("❌ Delete failed: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không thể xoá thông báo")),
          );
        }
      }
    }
  }

  String _notificationText(String type) {
    switch (type) {
      case 'like':
        return 'đã thích bài viết của bạn';
      case 'follow':
        return 'đã theo dõi bạn';
      default:
        return 'đã thực hiện một hành động';
    }
  }

  void _onNotificationTap(NotificationModel n) {
    if (n.postId != null) {
      // TODO: Điều hướng đến bài viết
      print("📌 Mở bài viết: ${n.postId}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
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
        title: const Text("Thông báo", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            tooltip: "Xoá tất cả",
            onPressed: _confirmDeleteAll,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final isSelected = selectedTab == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedTab = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isSelected ? Colors.blue : Colors.grey[800],
                    ),
                    child: Text(
                      tabs[index],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Expanded(
            child: RefreshIndicator(
              color: Colors.white,
              onRefresh: _initData,
              child: notifications.isEmpty
                  ? const Center(
                child: Text("Hiện chưa có thông báo", style: TextStyle(color: Colors.grey)),
              )
                  : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return Dismissible(
                    key: Key(n.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Xác nhận"),
                          content: const Text("Bạn có muốn xoá thông báo này?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Huỷ")),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xoá")),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) {
                      setState(() {
                        notifications.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xoá thông báo")));
                      // TODO: Gọi API xoá từng thông báo nếu bạn muốn
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () => _onNotificationTap(n),
                      leading: CircleAvatar(
                        backgroundImage: n.from.profileImg != null ? NetworkImage(n.from.profileImg!) : null,
                        child: n.from.profileImg == null ? const Icon(Icons.person) : null,
                      ),
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: n.from.username,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            TextSpan(
                              text: ' ${_notificationText(n.type)}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Text(
                        n.read ? 'Đã đọc' : 'Chưa đọc',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );

                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
