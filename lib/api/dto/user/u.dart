class UserModel {
  final String id;
  final String username;
  final String email;
  final String? fullname;
  final String? profileImg;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.fullname,
    this.profileImg,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullname: json['fullname'],
      profileImg: json['profileImg'],
    );
  }
}
