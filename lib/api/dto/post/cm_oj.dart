class CMObject {
  final String id;
  final String text;
  final String? user;

  CMObject({
    required this.id,
    required this.text,
    this.user,
  });

  factory CMObject.fromJson(Map<String, dynamic> json) {
    return CMObject(
      id: json['_id'] ?? '',
      text: json['text'] ?? '',
      user: json['user'] is Map ? json['user']['_id'] : json['user']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'text': text,
      'user': user,
    };
  }
}
