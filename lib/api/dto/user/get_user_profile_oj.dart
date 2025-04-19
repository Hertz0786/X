class GetUserProfile {
  final String username;

  GetUserProfile({required this.username});

  factory GetUserProfile.fromJson(Map<String, dynamic> json) {
    return GetUserProfile(
      username: json['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
    };
  }
}
