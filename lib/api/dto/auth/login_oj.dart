class LoginObject {
  String username;
  String password;

  LoginObject({
    required this.username,
    required this.password,
  });

  factory LoginObject.fromJson(Map<String, dynamic> json) => LoginObject(
    username: json['username']??'',
    password: json['password']??'',
  );

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}