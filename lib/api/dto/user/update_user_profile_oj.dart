class UpdateUserProfile {
  final String? fullname;
  final String? bio;
  final String? link;
  final String? email;
  final String? username;
  final String? currentPassword;
  final String? newPassword;
  final String? profileImg; // base64 hoặc link tạm
  final String? coverImg;   // base64 hoặc link tạm
  final String token; // Thêm token vào

  UpdateUserProfile({
    this.fullname,
    this.bio,
    this.link,
    this.email,
    this.username,
    this.currentPassword,
    this.newPassword,
    this.profileImg,
    this.coverImg,
    required this.token, // Yêu cầu token khi khởi tạo
  });

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'bio': bio,
      'link': link,
      'email': email,
      'username': username,
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'profileImg': profileImg,
      'coverImg': coverImg,
      'token': token, // Thêm token vào body
    };
  }

  factory UpdateUserProfile.fromJson(Map<String, dynamic> json) {
    return UpdateUserProfile(
      fullname: json['fullname'],
      bio: json['bio'],
      link: json['link'],
      email: json['email'],
      username: json['username'],
      currentPassword: json['currentPassword'],
      newPassword: json['newPassword'],
      profileImg: json['profileImg'],
      coverImg: json['coverImg'],
      token: json['token'],
    );
  }
}
