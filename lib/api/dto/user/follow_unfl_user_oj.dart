class FollowUnflUse {
  final String token;

  FollowUnflUse({required this.token});

  factory FollowUnflUse.fromJson(Map<String, dynamic> json) {
    return FollowUnflUse(
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}
