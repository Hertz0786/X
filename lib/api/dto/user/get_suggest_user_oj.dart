class GetSuggestUser {
  final String token;

  GetSuggestUser({required this.token});

  factory GetSuggestUser.fromJson(Map<String, dynamic> json) {
    return GetSuggestUser(
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}
