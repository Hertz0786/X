class DeleteNotificationObject {
  final String token;

  // Constructor sử dụng tên lớp đúng
  DeleteNotificationObject({required this.token});

  // Phương thức fromJson chuyển đổi từ JSON thành đối tượng
  factory DeleteNotificationObject.fromJson(Map<String, dynamic> json) {
    return DeleteNotificationObject( // Đảm bảo tên lớp đúng
      token: json['token'] ?? '', // Giả sử API trả về token
    );
  }

  // Chuyển đối tượng thành JSON để gửi lên API nếu cần
  Map<String, dynamic> toJson() {
    return {
      'token': token, // Gửi lại token
    };
  }
}
