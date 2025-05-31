import 'cm_oj.dart';

class CreatePostObject {
  final String? id;
  final String? text;
  final String? image;
  final String? token;
  final String? userId;
  final String? username;
  final String? fullname;
  final String? createdAt;
  final List<String>? likes;
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
    final dynamic user = json['user'];
    String? userId;
    String? username;
    String? fullname;
    String? profileImg;

    if (user is Map<String, dynamic>) {
      userId = user['_id'];
      username = user['username'];
      fullname = user['fullname'];
      profileImg = user['profileImg'];
    } else if (user is String) {
      userId = user;
    }

    return CreatePostObject(
      id: json['_id'],
      text: json['text'],
      image: json['image'],
      token: json['token'],
      userId: userId,
      username: username,
      fullname: fullname,
      profileImg: profileImg,
      createdAt: json['createdAt'],
      likes: (json['likes'] as List?)?.cast<String>(),
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
    List<CMObject>? comments,
    List<String>? likes,
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
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      profileImg: profileImg ?? this.profileImg,
    );
  }
}
