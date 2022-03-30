class User {
  String uniqueIdentifier;
  String email;
  bool notifyByEmail;

  User(
      {required this.uniqueIdentifier,
      required this.email,
      required this.notifyByEmail});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        uniqueIdentifier: json['uniqueIdentifier'],
        email: json['email'],
        notifyByEmail: json['notifyByEmail']);
  }

  Map<String, dynamic> toJson() => {
        'uniqueIdentifier': uniqueIdentifier,
        'email': email,
        'notifyByEmail': notifyByEmail
      };
}
