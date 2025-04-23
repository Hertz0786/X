import 'cm_oj.dart';

class CreatePostObject {
  final String? id;
  final String? text;
  final String? image;
  final String? token;
  final String? userId;
  final String? createdAt;
  final List<dynamic>? likes;
  final List<CMObject> comments;

  CreatePostObject({
    this.id,
    this.text,
    this.image,
    this.token,
    this.userId,
    this.createdAt,
    this.likes,
    this.comments = const [],
  });

  factory CreatePostObject.fromJson(Map<String, dynamic> json) {
    return CreatePostObject(
      id: json['_id'],
      text: json['text'],
      image: json['image'],
      token: json['token'],
      userId: json['user'] is Map ? json['user']['_id'] : json['user']?.toString(),
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
