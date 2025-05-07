import 'package:flutter/material.dart';
import 'package:kotlin/screens_event/user/profile_screen.dart';
import 'package:kotlin/screens_event/message/compose_message_screnn.dart';
import 'package:kotlin/screens_event/message/chat_detail_screen.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/auth/auth_me_api.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/client/mess/mess_api.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';
import 'package:kotlin/api/dto/mess/mess_oj.dart';
import 'package:kotlin/api/dto/mess/chat_user.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  GetMeObject? currentUser;
  List<ChatUser> _chatUsers = [];

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
    await _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final chats = await MessageApi().getChatPartners();
      setState(() => _chatUsers = chats);
    } catch (e) {
      debugPrint("❌ Lỗi load chats: $e");
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
          onTap: () {
            // Truyền currentUserId vào ProfileScreen khi nhấn vào avatar
            if (currentUser != null && currentUser!.id != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(userId: currentUser!.id!), // Truyền userId vào ProfileScreen
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: currentUser?.profileImg != null && currentUser!.profileImg!.isNotEmpty
                ? CircleAvatar(backgroundImage: NetworkImage(currentUser!.profileImg!))
                : CircleAvatar(
              backgroundColor: Colors.purple,
              child: Text(
                (currentUser?.fullname ?? currentUser?.username ?? 'U')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        title: const Text("Tin nhắn", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chào mừng tới hộp thư đến của bạn!',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              'Drop a line, share posts and more with private conversations between you and others on X.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ComposeMessageScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text("Viết tin nhắn"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _chatUsers.isEmpty
                  ? const Center(child: Text("Chưa có cuộc trò chuyện nào", style: TextStyle(color: Colors.grey)))
                  : ListView.separated(
                itemCount: _chatUsers.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.grey),
                itemBuilder: (_, index) {
                  final chat = _chatUsers[index];
                  final user = chat.user;
                  final message = chat.lastMessage;

                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            receiverId: user.id,
                            receiverName: user.fullname ?? user.username,
                            receiverAvatar: user.profileImg,
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundImage: (user.profileImg != null && user.profileImg!.isNotEmpty)
                          ? NetworkImage(user.profileImg!)
                          : null,
                      backgroundColor: Colors.purple,
                      child: (user.profileImg == null || user.profileImg!.isEmpty)
                          ? Text(
                        user.fullname?[0].toUpperCase() ?? 'U',
                        style: const TextStyle(color: Colors.white),
                      )
                          : null,
                    ),
                    title: Text(user.fullname ?? user.username, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      message.text ?? "[Ảnh]",
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
