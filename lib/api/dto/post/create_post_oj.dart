class CreatePostObject {
  String? id;
  String? text;
  String? image;
  String? token;

  CreatePostObject({
    this.id,
    this.text,
    this.image,
    this.token,
  });

  factory CreatePostObject.fromJson(Map<String, dynamic> json) => CreatePostObject(
    id: json['_id'] ?? '', // ✅ lấy _id từ backend
    text: json['text'],
    image: json['image'],
    token: json['token'],
  );

  Map<String, dynamic> toJson() => {
    'text': text,
    'image': image,
    'token': token,
  };
}
