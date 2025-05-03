import "cm_oj.dart";

class CreatePostObject {
  final String? id;
  final String? text;
  final String? image;
  final String? token;
  final String? userId;
  final String? username;
  final String? fullname;
  final String? createdAt;
  final List<dynamic>? likes;
  final List<CMObject> comments;
  final String? profileImg;

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
    this.profileImg,
  });

  factory CreatePostObject.fromJson(Map<String, dynamic> json) {
    final user = json['user'];

    return CreatePostObject(
      id: json['_id'],
      text: json['text'],
      image: json['image'],
      token: json['token'],
      profileImg: user is Map ? user['profileImg'] : null,
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

  CreatePostObject copyWith({
    String? username,
    String? fullname,
    String? profileImg,
  }) {
    return CreatePostObject(
      id: id,
      text: text,
      image: image,
      token: token,
      userId: userId,
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      createdAt: createdAt,
      likes: likes,
      comments: comments,
      profileImg: profileImg ?? this.profileImg,
    );
  }
}
