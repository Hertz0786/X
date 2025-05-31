import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/client/user/get_user.dart';
import 'package:kotlin/api/dto/post/cm_oj.dart';

class PostSearchResult {
  final String? id;
  final String? userId;
  final String text;
  final String? image;

  String? authorName;
  String? authorProfileImg;
  final List<String> likes;
  final List<CMObject> comments;

  PostSearchResult({
    this.id,
    this.userId,
    required this.text,
    this.image,
    this.authorName,
    this.authorProfileImg,
    this.likes = const [],
    this.comments = const [],
  });

  factory PostSearchResult.fromJson(Map<String, dynamic> json) {
    return PostSearchResult(
      id: json['_id'],
      userId: json['user'],
      text: json['text'] ?? '',
      image: json['image'],
      likes: List<String>.from(json['likes'] ?? []),
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => CMObject.fromJson(e))
          .toList() ??
          [],
    );
  }

  Future<void> fetchAuthorName(GetUser getUser) async {
    try {
      final user = await getUser.fetchProfileById(userId!);
      authorName = user.fullname ?? user.username ?? 'Ẩn danh';
      authorProfileImg = user.profileImg;
    } catch (e) {
      authorName = "Ẩn danh";
      authorProfileImg = null;
    }
  }

  CreatePostObject toCreatePostObject() {
    return CreatePostObject(
      id: id,
      userId: userId,
      text: text,
      image: image,
      fullname: authorName,
      profileImg: authorProfileImg,
      likes: likes,
      comments: comments,
    );
  }

  PostSearchResult toSearchResult(String? name, String? img) {
    return PostSearchResult(
      id: id,
      userId: userId,
      text: text,
      image: image,
      authorName: name,
      authorProfileImg: img,
      likes: likes,
      comments: comments,
    );
  }
}
