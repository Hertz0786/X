class LikeUnLikePostObject {
  final String id; // ID của bài viết
  final String token; // ID của người dùng

  LikeUnLikePostObject({
    required this.id,
    required this.token,
  });

  // Phương thức chuyển JSON thành đối tượng LikeUnLikePostObject
  factory LikeUnLikePostObject.fromJson(Map<String, dynamic> json) {
    return LikeUnLikePostObject(
      id: json['id'] ?? '',
      token: json['token'] ?? '',
    );
  }
}
// Phương thức chuyển đối tượng thành JSON để gửi
