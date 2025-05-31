import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/client/user/get_user.dart';

class PostSearchResult {
  final String? id;
  final String? userId;
  final String text;
  final String? image;

  String? authorName;
  String? authorProfileImg;

  PostSearchResult({
    this.id,
    this.userId,
    required this.text,
    this.image,
    this.authorName,
    this.authorProfileImg,
  });

  factory PostSearchResult.fromJson(Map<String, dynamic> json) {
    return PostSearchResult(
      id: json['_id'],
      userId: json['user'],
      text: json['text'] ?? '',
      image: json['image'],
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
    );
  }
}
