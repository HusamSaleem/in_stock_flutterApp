import 'package:in_stock_tracker/authentication/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  void saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("uniqueIdentifier", user.uniqueIdentifier);
    prefs.setString("email", user.email);
    prefs.setBool("notifyByEmail", user.notifyByEmail);
  }

  Future<User> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? uniqueIdentifier = prefs.getString("uniqueIdentifier");
    String? email = prefs.getString("email");
    bool? notifyByEmail = prefs.getBool("notifyByEmail");

    return User(
        uniqueIdentifier: uniqueIdentifier!,
        email: email!,
        notifyByEmail: notifyByEmail!);
  }

  void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("uniqueIdentifier");
    prefs.remove("email");
    prefs.remove("notifyByEmail");
  }

  Future<String?> getUniqueId(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("uniqueIdentifier");
    return token;
  }
}
