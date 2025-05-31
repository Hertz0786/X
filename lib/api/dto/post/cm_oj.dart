class CMObject {
  final String id;
  final String text;
  final String user;

  CMObject({
    required this.id,
    required this.text,
    required this.user,
  });

  factory CMObject.fromJson(Map<String, dynamic> json) {
    return CMObject(
      id: json['_id'] ?? '',
      text: json['text'] ?? '',
      user: json['user'] ?? '',
    );
  }
}
