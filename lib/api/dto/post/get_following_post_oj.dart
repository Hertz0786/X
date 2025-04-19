class GetFollowingPost {
  final String token;

  GetFollowingPost({required this.token});

  factory GetFollowingPost.fromJson(Map<String, dynamic> json) {
    return GetFollowingPost(
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}
