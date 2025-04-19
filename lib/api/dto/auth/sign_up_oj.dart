class SignUpObject {
  String username;
  String fullname;
  String password;
  String email;
  SignUpObject({
    required this.username,
    required this.fullname,
    required this.password,
    required this.email,
  });

  factory SignUpObject.fromJson(Map<String, dynamic> json) => SignUpObject(
    username: json['username']??'',
    fullname: json['fullname']??'',
    password: json['password']??'',
    email: json['email']??'',
  );

  Map<String, dynamic> toJson() => {
    'username': username,
    'fullname': fullname,
    'password': password,
    'email': email,
  };
}
