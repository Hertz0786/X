class GetUserProfileObject {
  final String username;

  GetUserProfileObject({required this.username});

  factory GetUserProfileObject.fromJson(Map<String, dynamic> json) {
    return GetUserProfileObject(
      username: json['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
    };
  }
}
