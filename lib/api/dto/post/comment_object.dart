class CommentObject {
  final String idpost;
  final String text;

  CommentObject({
    required this.idpost,
    required this.text,
  });

  factory CommentObject.fromJson(Map<String, dynamic> json) {
    return CommentObject(
      idpost: json['idpost'] ?? '',
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idpost': idpost,
      'text': text,
    };
  }
}
