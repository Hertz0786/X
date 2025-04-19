class GetNotificationObject {
  final String token;

  GetNotificationObject({required this.token}); // Sửa tên constructor từ GetMeObject thành GetNotificationObject

  factory GetNotificationObject.fromJson(Map<String, dynamic> json) {
    return GetNotificationObject( // Đảm bảo tên lớp đúng
      token: json['token'] ?? '', // Giả sử API trả về token
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token, // Gửi lại token
    };
  }
}
