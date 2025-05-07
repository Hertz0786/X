import 'package:kotlin/api/client/user/get_user.dart';

class PostSearchResult {
  final String id;
  final String text;
  final String? image;
  final String userId;
  String authorName = 'Unknown'; // Giá trị mặc định cho tên tác giả

  PostSearchResult({
    required this.id,
    required this.text,
    this.image,
    required this.userId,
  });

  // Phương thức để lấy tên tác giả từ API
  Future<void> fetchAuthorName(GetUser getUser) async {
    try {
      final profile = await getUser.fetchProfileById(userId); // Gọi API để lấy thông tin người dùng
      authorName = profile.username ?? 'Unknown'; // Cập nhật tên người dùng
    } catch (e) {
      print("Lỗi khi lấy tên tác giả: $e");
      authorName = 'Unknown'; // Nếu có lỗi, tên tác giả vẫn là 'Unknown'
    }
  }

  // Factory constructor để khởi tạo từ JSON
  factory PostSearchResult.fromJson(Map<String, dynamic> json) {
    return PostSearchResult(
      id: json['_id'],
      text: json['text'],
      image: json['image'],
      userId: json['user'], // userId từ trường 'user' trong JSON
    );
  }
}
