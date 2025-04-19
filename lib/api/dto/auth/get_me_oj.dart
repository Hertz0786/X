class GetMeObject {
  final String token;

  GetMeObject({required this.token});

  factory GetMeObject.fromJson(Map<String, dynamic> json) {
    return GetMeObject(
      token: json['token'] ?? '', // Giả sử API trả về token
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token, // Gửi lại token
    };
  }
}
