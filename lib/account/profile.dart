import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:in_stock_tracker/account/profile_provider.dart';
import 'package:in_stock_tracker/authentication/user_provider.dart';
import 'package:in_stock_tracker/utils/local_persistence.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  String? _newEmail;
  bool preferenceChange = false;

  bool isEmailValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    ProfileProvider profileProvider = Provider.of<ProfileProvider>(context);
    double screenHeight = MediaQuery.of(context).size.height;

    var updateInfo = () {
      if (_formKey.currentState!.validate()) {
        FlushbarHelper.createInformation(
                message: 'Updating information',
                duration: const Duration(seconds: 2))
            .show(context);

        if (userProvider.user!.email.compareTo(_newEmail!) != 0) {
          profileProvider
              .updateEmail(userProvider.user!.uniqueIdentifier, _newEmail!)
              .then((response) {
            if (response['status']) {
              FlushbarHelper.createSuccess(
                      message: "Email successfully updated!",
                      duration: const Duration(seconds: 3))
                  .show(context);
              userProvider.user!.email = _newEmail!;
              UserPreferences().saveUser(userProvider.user!);
            } else {
              FlushbarHelper.createError(
                      title: "Error",
                      message: "Failed to update email, try again",
                      duration: const Duration(seconds: 3))
                  .show(context);
            }
          });
        }

        if (preferenceChange) {
          profileProvider
              .updateNotificationPreference(userProvider.user!.uniqueIdentifier,
                  userProvider.user!.notifyByEmail)
              .then((response) {
            if (response['status']) {
              FlushbarHelper.createSuccess(
                      message: "Preference successfully updated!",
                      duration: const Duration(seconds: 3))
                  .show(context);
              preferenceChange = false;
              UserPreferences().saveUser(userProvider.user!);
            } else {
              FlushbarHelper.createError(
                      title: "Error",
                      message: "Failed to update preference, try again",
                      duration: const Duration(seconds: 3))
                  .show(context);
            }
          });
        }
      }
    };

    return Scaffold(
      backgroundColor: Colors.black12,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(height: screenHeight * 0.05),
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                child: TextFormField(
                  controller: TextEditingController()
                    ..text = userProvider.user!.email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.white),
                      icon: Icon(Icons.email),
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid email address';
                    }
                    if (!isEmailValid(value)) {
                      return 'Please enter a valid email address';
                    }
                    _newEmail = value;
                    return null;
                  },
                ),
              ),
              SizedBox(height: screenHeight * 0.025),
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                child: CheckboxListTile(
                  title: const Text("Notify by Email"),
                  value: userProvider.user!.notifyByEmail,
                  checkColor: Colors.white,
                  activeColor: Colors.black54,
                  onChanged: (newValue) {
                    setState(() {
                      userProvider.user!.notifyByEmail = newValue!;
                      preferenceChange = true;
                    });
                  },
                ),
              ),
              SizedBox(height: screenHeight * 0.075),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue[400],
                  minimumSize: Size(0, 50),
                  elevation: 4,
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(64),
                  ),
                ),
                onPressed: updateInfo,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
