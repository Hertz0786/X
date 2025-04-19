class CreatePostObject {
  final String text;
  final String? image; // Ảnh có thể là null
  final String token; // Thêm token vào lớp

  CreatePostObject({
    required this.text,
    this.image, // Ảnh là tùy chọn
    required this.token, // Token là bắt buộc khi tạo bài viết
  });

  // Phương thức chuyển JSON thành đối tượng CreatePostObject
  factory CreatePostObject.fromJson(Map<String, dynamic> json) {
    return CreatePostObject(
      text: json['text'] ?? '', // Lấy text từ JSON
      image: json['image'], // Lấy image từ JSON, nếu có
      token: json['token'] ?? '', // Lấy token từ JSON
    );
  }

  // Phương thức chuyển đối tượng CreatePostObject thành JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text, // Gửi text
      'image': image, // Gửi image (nếu có)
      'token': token, // Gửi token
    };
  }
}
