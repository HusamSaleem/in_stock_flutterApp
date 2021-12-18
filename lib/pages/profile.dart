import 'dart:convert';

import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_stock_tracker/services/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  bool infoChanged = false;
  bool flagsChanged = false;

  Future<void> saveUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userInfo', jsonEncode(user));
  }

  bool isEmailValid(email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  bool isPhoneNumberValid(phoneNumber) {
    return RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)').hasMatch(phoneNumber);
  }

  Future getUniqueID() async {
    if (user.email == null && user.phoneNumber == null) {
      return;
    }

    String query = (user.email != null && user.phoneNumber != null)
        ? "?email=${user.email}?number=${user.phoneNumber}"
        : (user.email != null)
            ? "?email=${user.email}"
            : "?number=${user.phoneNumber}";
    final response = await http.get(Uri.parse('$server$getUniqueIDLink$query'),
        headers: headers);

    if (response.statusCode == 200) {
      String uniqueID = json.decode(response.body)['uniqueID'].toString();
      user.uniqueID = uniqueID;
      return uniqueID;
    } else {
      await FlushbarHelper.createError(
              message:
                  'Something went wrong... Make sure to have correct information',
              title: 'Error',
              duration: const Duration(seconds: 2))
          .show(context);
    }
  }

  Future updateUserNotifications() async {
    if (user.email == null && user.phoneNumber == null) {
      return;
    }

    var body = json.encode({
      "uniqueID": (user.uniqueID == null) ? await getUniqueID() : user.uniqueID,
      "notifyByEmail": user.notifyByEmail,
      "notifyByNumber": user.notifyByPhoneNumber
    });

    final response = await http.put(
        Uri.parse('$server$updateUserNotificationsLink'),
        body: body,
        headers: headers);

    if (response.statusCode == 200) {
      FlushbarHelper.createSuccess(
              message: 'Successfully updated!',
              title: 'Success',
              duration: const Duration(seconds: 2))
          .show(context);
    } else {
      await FlushbarHelper.createError(
              message: 'Failed to update user notification preferences',
              title: 'Error',
              duration: const Duration(seconds: 2))
          .show(context);
    }
  }

  Future updateUserInfo() async {
    var body = json.encode({
      "uniqueID": (user.uniqueID == null) ? await getUniqueID() : user.uniqueID,
      "email": (user.email == null) ? "" : user.email,
      "number": (user.phoneNumber == null) ? "" : user.phoneNumber
    });

    final response = await http.put(Uri.parse('$server$updateUserInfoLink'),
        body: body, headers: headers);

    if (response.statusCode == 200) {
      String newUniqueID = json.decode(response.body)['uniqueID'].toString();
      user.uniqueID = newUniqueID;
      FlushbarHelper.createSuccess(
              message: 'Successfully updated!',
              title: 'Success',
              duration: const Duration(seconds: 2))
          .show(context);
    } else {
      await FlushbarHelper.createError(
              message: 'Failed to update user information',
              title: 'Error',
              duration: const Duration(seconds: 2))
          .show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Form(
        autovalidateMode: AutovalidateMode.always,
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 0.0, 50.0, 15.0),
              child: TextFormField(
                controller: TextEditingController()
                  ..text = ((user.email != null) ? user.email : "")!,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: Colors.white),
                  icon: Icon(
                    Icons.email,
                    color: Colors.black54,
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty && user.email == null) {
                    return null;
                  }

                  if (value.isNotEmpty && !isEmailValid(value)) {
                    return 'Please enter a valid email address';
                  }
                  if (user.email != value) {
                    infoChanged = true;
                    user.email = value;
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 0.0, 50.0, 15.0),
              child: TextFormField(
                controller: TextEditingController()
                  ..text =
                      ((user.phoneNumber != null) ? user.phoneNumber : "")!,
                keyboardType: TextInputType.number,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  labelStyle: TextStyle(color: Colors.white),
                  icon: Icon(
                    Icons.smartphone_rounded,
                    color: Colors.black54,
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty && user.phoneNumber == null) {
                    return null;
                  }

                  if (value.isNotEmpty && !isPhoneNumberValid(value)) {
                    return 'Please enter a valid phone number';
                  }

                  if (user.phoneNumber != value) {
                    infoChanged = true;
                    user.phoneNumber = value;
                  }
                  return null;
                },
              ),
            ),
            CheckboxListTile(
              title: const Text("Notify by Email"),
              value: (user.notifyByEmail == null) ? false : user.notifyByEmail,
              checkColor: Colors.white,
              activeColor: Colors.black54,
              onChanged: (newValue) {
                setState(() {
                  user.notifyByEmail = newValue!;
                  flagsChanged = true;
                });
              },
            ),
            CheckboxListTile(
              title: const Text("Notify by Phone Number"),
              value: (user.notifyByPhoneNumber == null)
                  ? false
                  : user.notifyByPhoneNumber,
              checkColor: Colors.white,
              activeColor: Colors.black54,
              onChanged: (newValue) {
                setState(() {
                  user.notifyByPhoneNumber = newValue!;
                  flagsChanged = true;
                });
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.green[600]),
              onPressed: () async {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  FlushbarHelper.createInformation(
                          message: 'Updating information',
                          duration: const Duration(seconds: 2))
                      .show(context);

                  if (infoChanged) {
                    await updateUserInfo();
                    saveUserInfo();
                    infoChanged = false;
                  }

                  if (flagsChanged) {
                    await updateUserNotifications();
                    saveUserInfo();
                    flagsChanged = false;
                  }
                } else {
                  await FlushbarHelper.createError(
                          message:
                              'Must have at least an email or phone number',
                          title: 'Error',
                          duration: const Duration(seconds: 2))
                      .show(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
