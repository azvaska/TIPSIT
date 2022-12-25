class User {
  final String userId;
  final String? email;
  String token = "";
  User({required this.token, this.email, required this.userId});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      email: json['email'],
      token: json['token'],
    );
  }
}
