import "cm_oj.dart";


class CreatePostObject {
  final String? id;
  final String? text;
  final String? image; // ✅ base64 string with data:image/jpeg;base64,...
  final String? token;
  final String? userId;
  final String? username;
  final String? fullname;
  final String? createdAt;
  final List<dynamic>? likes;
  final List<CMObject> comments;

  CreatePostObject({
    this.id,
    this.text,
    this.image,
    this.token,
    this.userId,
    this.username,
    this.fullname,
    this.createdAt,
    this.likes,
    this.comments = const [],
  });

  factory CreatePostObject.fromJson(Map<String, dynamic> json) {
    final user = json['user'];

    return CreatePostObject(
      id: json['_id'],
      text: json['text'],
      image: json['image'],
      token: json['token'],
      userId: user is Map ? user['_id'] : user?.toString(),
      username: user is Map ? user['username'] : null,
      fullname: user is Map ? user['fullname'] : null,
      createdAt: json['createdAt'],
      likes: json['likes'] as List? ?? [],
      comments: (json['comments'] as List? ?? [])
          .map((e) => CMObject.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'image': image,
    'token': token,
  };
}
