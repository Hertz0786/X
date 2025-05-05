import 'package:kotlin/api/dto/auth/get_me_oj.dart';
import 'package:kotlin/api/dto/mess/mess_oj.dart';

class ChatUser {
  final GetMeObject user;
  final MessageModel lastMessage;

  ChatUser({required this.user, required this.lastMessage});

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      user: GetMeObject.fromJson(json['user']),
      lastMessage: MessageModel.fromJson(json['lastMessage']),
    );
  }
}
