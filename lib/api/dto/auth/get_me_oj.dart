class GetMeObject {
  final String id;
  final String username;
  final String email;
  final String? fullname;
  final String? bio;
  final String? profileImg;
  final String? coverImg;

  GetMeObject({
    required this.id,
    required this.username,
    required this.email,
    this.fullname,
    this.bio,
    this.profileImg,
    this.coverImg,
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
    );
  }
}
