User user = User();

class User {
  // ignore: avoid_init_to_null
  String? uniqueID = null;

  // ignore: avoid_init_to_null
  String? email = null;

  // ignore: avoid_init_to_null
  String? phoneNumber = null;

  late bool? notifyByEmail;
  late bool? notifyByPhoneNumber;

  User(
      {this.uniqueID,
      this.email,
      this.phoneNumber,
      this.notifyByEmail,
      this.notifyByPhoneNumber});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        uniqueID: json['uniqueID'],
        email: json['email'],
        phoneNumber: json['phoneNumber'],
        notifyByPhoneNumber: json['notifyByNumber'],
        notifyByEmail: json['notifyByEmail']);
  }

  Map<String, dynamic> toJson() => {
        'uniqueID': uniqueID,
        'email': email,
        'phoneNumber': phoneNumber,
        'notifyByNumber': notifyByPhoneNumber,
        'notifyByEmail': notifyByEmail
      };
}
