class CommentOnPostObject {
  final String idpost;       // postId
  final String text;
  final String token;

  CommentOnPostObject({
    required this.idpost,
    required this.text,
    required this.token,
  });

  factory CommentOnPostObject.fromJson(Map<String, dynamic> json) =>
      CommentOnPostObject(
        idpost: json['idpost'] ?? '',
        text: json['text'] ?? '',
        token: json['token'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'text': text, // chỉ cần gửi text trong body
  };

  static Future<CommentOnPostObject> fromLocalStorage({
    required String idpost,
    required String text,
    required String token,
  }) async {
    // Không cần lấy userId nữa vì backend đã dùng token để xác định
    return CommentOnPostObject(
      idpost: idpost,
      text: text,
      token: token,
    );
  }
}
