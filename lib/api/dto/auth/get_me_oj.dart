class GetMeObject {
  final String id;
  final String username;
  final String email;
  final String? fullname;
  final String? bio;
  final String? profileImg;
  final String? coverImg;
  final List<String> following; // 👈 thêm dòng này

  GetMeObject({
    required this.id,
    required this.username,
    required this.email,
    this.fullname,
    this.bio,
    this.profileImg,
    this.coverImg,
    this.following = const [], // 👈 khởi tạo mặc định
  });

  factory GetMeObject.fromJson(Map<String, dynamic> json) {
    return GetMeObject(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullname: json['fullname'],
      bio: json['bio'],
      profileImg: json['profileImg'],
      coverImg: json['coverImg'],
      following: List<String>.from(json['following'] ?? []), // 👈 parse JSON
    );
  }
}
