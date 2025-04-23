class DeletePostObject {
  final String idpost;

  DeletePostObject({required this.idpost});

  // Phương thức chuyển đổi từ JSON sang đối tượng Dart
  factory DeletePostObject.fromJson(Map<String, dynamic> json) {
    return DeletePostObject(
      idpost: json['idpost'] ?? '', // Lấy id từ JSON
    );
  }

  // Phương thức chuyển đổi đối tượng Dart thành JSON
  Map<String, dynamic> toJson() {
    return {
      'idpost': idpost, // Gửi id của bài viết cần xóa
    };
  }
}
