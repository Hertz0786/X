class UserProfileUpdateRequest {
  final String? fullname;
  final String? bio;
  final String? link;
  final String? email;
  final String? username;
  final String? currentPassword;
  final String? newPassword;
  final String? profileImg; // base64 hoặc link ảnh tạm
  final String? coverImg;   // base64 hoặc link ảnh tạm

  UserProfileUpdateRequest({
    this.fullname,
    this.bio,
    this.link,
    this.email,
    this.username,
    this.currentPassword,
    this.newPassword,
    this.profileImg,
    this.coverImg,
  });

  Map<String, dynamic> toJson() => {
    if (fullname != null) 'fullname': fullname,
    if (bio != null) 'bio': bio,
    if (link != null) 'link': link,
    if (email != null) 'email': email,
    if (username != null) 'username': username,
    if (currentPassword != null) 'currentPassword': currentPassword,
    if (newPassword != null) 'newPassword': newPassword,
    if (profileImg != null) 'profileImg': profileImg,
    if (coverImg != null) 'coverImg': coverImg,
  };
}
