class GetLikedPostObject {
  final String token;

  GetLikedPostObject({required this.token});

  factory GetLikedPostObject.fromJson(Map<String, dynamic> json) {
    return GetLikedPostObject(
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}
