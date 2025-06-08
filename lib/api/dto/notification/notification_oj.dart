class NotificationModel {
  final String id;
  final String type;
  final String? postId;
  final bool read;
  final FromUser from;

  NotificationModel({
    required this.id,
    required this.type,
    this.postId,
    required this.read,
    required this.from,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      type: json['type'],
      postId: json['post'] is Map<String, dynamic> ? json['post']['_id'] : json['post'],
      read: json['read'] ?? false,
      from: FromUser.fromJson(json['from']),
    );
  }
}

class FromUser {
  final String id;
  final String username;
  final String? profileImg;

  FromUser({
    required this.id,
    required this.username,
    this.profileImg,
  });

  factory FromUser.fromJson(Map<String, dynamic> json) {
    return FromUser(
      id: json['_id'],
      username: json['username'],
      profileImg: json['profileImg'],
    );
  }
}
