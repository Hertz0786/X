import 'package:kotlin/api/client/id_storage.dart';
import 'package:kotlin/api/client/token_storage.dart';


class CommentOnPostObject {
  final String id;
  final String text;
  final String userId;
  final String token;

  CommentOnPostObject({
    required this.id,
    required this.text,
    required this.userId,
    required this.token,
  });

  factory CommentOnPostObject.fromJson(Map<String, dynamic> json) =>
      CommentOnPostObject(
        id: json['id'] ?? '',
        text: json['text'] ?? '',
        userId: json['user'] ?? '',
        token: json['token'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'text': text,
    'user': userId,
  };

  static Future<CommentOnPostObject> fromLocalStorage({
    required String id,
    required String text,
    required String token,
  }) async {
    final userId = await IdStorage.getUserId();
    if (userId == null) throw Exception("Chưa đăng nhập");

    return CommentOnPostObject(
      id: id,
      text: text,
      userId: userId,
      token: token,
    );
  }
}

