import 'package:flutter/cupertino.dart';
import 'package:in_stock_tracker/authentication/user.dart';

class UserProvider with ChangeNotifier {
  User? _user = null;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
  }
}
