
class User {
  final String account;
  final String name;
  final String token;
  final String? jobTitle;
  final String? email;

  User({
    required this.account,
    required this.name,
    required this.token,
    this.jobTitle,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      account: json['account'] as String,
      name: json['name'] as String,
      token: json['token'] as String,
      jobTitle: json['jobTitle'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'name': name,
      'token': token,
      'jobTitle': jobTitle,
      'email': email,
    };
  }
}