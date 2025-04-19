class DeletePostObject {
  final String id;

  DeletePostObject({required this.id});

  // Phương thức chuyển đổi từ JSON sang đối tượng Dart
  factory DeletePostObject.fromJson(Map<String, dynamic> json) {
    return DeletePostObject(
      id: json['id'] ?? '', // Lấy id từ JSON
    );
  }

  // Phương thức chuyển đổi đối tượng Dart thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Gửi id của bài viết cần xóa
    };
  }
}
