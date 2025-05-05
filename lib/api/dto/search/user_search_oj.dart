class UserSearchResult {
  final String id;
  final String fullname;
  final String? username;
  final String? profileImg;

  UserSearchResult({
    required this.id,
    required this.fullname,
    this.username,
    this.profileImg,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['_id'],
      fullname: json['fullname'],
      username: json['username'],
      profileImg: json['profileImg'],
    );
  }
}
