import 'package:flutter/material.dart';
import 'package:kotlin/api/client/mess/mess_api.dart';
import 'package:kotlin/api/dto/mess/mess_oj.dart';
import 'package:kotlin/api/client/socket.dart';

class ChatDetailScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String? receiverAvatar;

  const ChatDetailScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<MessageModel> _messages = [];
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _socketService.connect();
    _socketService.onNewMessage((data) {
      final msg = MessageModel.fromJson(data);
      if (msg.senderId == widget.receiverId) {
        setState(() {
          _messages.add(msg);
        });
        _scrollToBottom();
      }
    });
  }

  Future<void> _loadMessages() async {
    try {
      final msgs = await MessageApi().getMessagesWithUser(widget.receiverId);
      setState(() => _messages.addAll(msgs));
      _scrollToBottom(delay: true);
    } catch (e) {
      debugPrint("❌ Load messages error: $e");
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      final sent = await MessageApi().sendMessage(
        receiverId: widget.receiverId,
        text: text,
      );
      _socketService.sendMessage(widget.receiverId, text);
      setState(() {
        _messages.add(sent);
        _controller.clear();
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint("❌ Send message error: $e");
    }
  }

  void _scrollToBottom({bool delay = false}) {
    Future.delayed(delay ? const Duration(milliseconds: 300) : Duration.zero, () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTimestamp(DateTime? dateTime) {
    if (dateTime == null) return '';
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.receiverAvatar != null
                  ? NetworkImage(widget.receiverAvatar!)
                  : null,
              backgroundColor: Colors.grey[700],
              child: widget.receiverAvatar == null
                  ? Text(
                widget.receiverName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              widget.receiverName,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg.senderId != widget.receiverId;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 300),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: msg.text != null
                            ? Text(
                          msg.text!,
                          style: const TextStyle(color: Colors.white),
                        )
                            : msg.image != null
                            ? Image.network(msg.image!)
                            : const Text(
                          "[Không có nội dung]",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, right: 8, left: 8),
                        child: Text(
                          _formatTimestamp(msg.createdAt),
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.grey),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
