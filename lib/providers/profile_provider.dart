import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import '../utils/constants.dart';

class ProfileProvider with ChangeNotifier {
  Future<bool> updateNotificationPreference(
      String uid, bool pushNotification) async {
    // Add in the unique id
    final Uri uri = Uri.parse(Constants.notification);
    Map<String, String> request = {
      "uid": uid,
      "pushNotifications": pushNotification.toString()
    };
    Response response = await patch(uri, body: jsonEncode(request), headers: Constants.headers);

    // Successfully updated email
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> createNewUser(
      String uid, String registrationToken) async {
    // Add in the unique id
    final Uri uri = Uri.parse(Constants.user);
    Map<String, String> request = {
      "uid": uid,
      "registrationToken": registrationToken
    };
    Response response = await post(uri, headers: Constants.headers, body: jsonEncode(request));

    // Successfully updated email
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> updateRegistrationToken(
      String uid, String registrationToken) async {
    // Add in the unique id
    final Uri uri = Uri.parse(Constants.token);
    Map<String, String> request = {
      "uid": uid,
      "registrationToken": registrationToken
    };
    Response response = await patch(uri, headers: Constants.headers, body: jsonEncode(request));

    // Successfully updated email
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> getUserNotificationPreference(
      String uid) async {
    // Add in the unique id
    final Uri uri = Uri.parse(Constants.notification + "/" + uid);
    Response response = await get(uri, headers: Constants.headers);
    return response.body.trim().compareTo("true") == 0;
  }
}
