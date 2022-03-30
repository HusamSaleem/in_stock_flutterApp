import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:in_stock_tracker/authentication/user.dart';
import 'package:in_stock_tracker/utils/app_url.dart';
import 'package:in_stock_tracker/utils/local_persistence.dart';

enum Status {
  NotLoggedIn,
  NotRegistered,
  LoggedIn,
  Registered,
  Authenticating,
  Registering,
  LoggedOut
}

class AuthProvider with ChangeNotifier {
  Status _loggedInStatus = Status.NotLoggedIn;
  Status _registeredInStatus = Status.NotRegistered;

  Status get loggedInStatus => _loggedInStatus;

  Status get registeredInStatus => _registeredInStatus;

  void set registeredInStatus(value) => _registeredInStatus = value;

  Future<Map<String, dynamic>> login(String email, String password) async {
    var result;

    final Map<String, dynamic> loginData = {
      "email": email,
      "password": password
    };

    _loggedInStatus = Status.Authenticating;
    notifyListeners();

    final uri = Uri.parse(AppUrl.login);
    Response response =
        await post(uri, body: json.encode(loginData), headers: AppUrl.headers);

    // Failed login
    if (response.statusCode != HttpStatus.ok) {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = {'status': false, 'message': json.decode(response.body)};
    } else {
      // Successful login
      User user = User.fromJson(json.decode(response.body));
      UserPreferences().saveUser(user);
      _loggedInStatus = Status.LoggedIn;
      notifyListeners();
      result = {'status': true, 'message': 'Successful', 'user': user};
    }
    return result;
  }

  // Should return status code 200 if user is registered successfully
  Future<int> register(String email, String password) async {
    final Map<String, dynamic> registrationData = {
      'email': email,
      'password': password
    };

    _registeredInStatus = Status.Registering;
    notifyListeners();

    final uri = Uri.parse(AppUrl.register);
    return await post(uri,
            body: json.encode(registrationData), headers: AppUrl.headers)
        .then((value) => value.statusCode);
  }
}
