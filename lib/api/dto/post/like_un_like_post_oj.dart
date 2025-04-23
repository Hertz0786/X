class LikeUnLikePostObject {
  final String idpost; // ID của bài viết
  final String token; // ID của người dùng

  LikeUnLikePostObject({
    required this.idpost,
    required this.token,
  });

  // Phương thức chuyển JSON thành đối tượng LikeUnLikePostObject
  factory LikeUnLikePostObject.fromJson(Map<String, dynamic> json) {
    return LikeUnLikePostObject(
      idpost: json['idpost'] ?? '',
      token: json['token'] ?? '',
    );
  }
}
// Phương thức chuyển đối tượng thành JSON để gửi
