class SignUpObject {
  final String username;
  final String fullname;
  final String password;
  final String email;
  final String? id;
  final String? token;

  SignUpObject({
    required this.username,
    required this.fullname,
    required this.password,
    required this.email,
    this.id,
    this.token,
  });

  factory SignUpObject.fromJson(Map<String, dynamic> json) {
    return SignUpObject(
      username: json['username'],
      fullname: json['fullname'] ?? '',
      password: '',
      email: json['email'],
      id: json['_Id'] ?? json['_id'],
      token: json['accessToken'],
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'fullname': fullname,
    'password': password,
    'email': email,
  };
}
