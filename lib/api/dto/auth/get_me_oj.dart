class UserObject {
  final String id;
  final String name;
  final String email;

  UserObject({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserObject.fromJson(Map<String, dynamic> json) => UserObject(
    id: json['_id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
  );
}
