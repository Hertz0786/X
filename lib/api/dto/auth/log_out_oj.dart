class LogOutObject {
  String userId;
  String token;

  LogOutObject({required this.userId, required this.token});

  factory LogOutObject.fromJson(Map<String, dynamic> json) => LogOutObject(
    userId: json['userId'] ?? '',
    token : json['token'],
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
  };
}
// useless