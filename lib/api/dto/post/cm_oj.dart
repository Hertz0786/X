class CMObject {
  final String text;
  final String? user;

  CMObject({
    required this.text,
    this.user,
  });

  factory CMObject.fromJson(Map<String, dynamic> json) {
    return CMObject(
      text: json['text'] ?? '',
      user: json['user'] is Map ? json['user']['_id'] : json['user']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'user': user,
    };
  }
}
