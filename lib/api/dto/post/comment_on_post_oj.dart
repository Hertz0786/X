class CommentOnPostObject {
  String id;
  String text;
  String token;

  CommentOnPostObject({
    required this.id,
    required this.text,
    required this.token,
  });

  factory CommentOnPostObject.fromJson(Map<String, dynamic> json) =>
      CommentOnPostObject(
        id: json['id'] ?? '',
        text: json['text'] ?? '',
        token: json['token'] ?? '',
      );

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'text': text,
        'token': token,
      };
}