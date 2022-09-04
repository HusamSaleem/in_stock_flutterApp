import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:in_stock_tracker_new/providers/authentication_service.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool sendNotifications = false;
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _getNotificationPreference();
  }

  void _getNotificationPreference() async {
    String uuid = context.read<AuthenticationService>().getUuid().toString();
    sendNotifications = await Provider.of<ProfileProvider>(context, listen: false).getUserNotificationPreference(uuid);
    setState(() {
      sendNotifications = sendNotifications;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    ProfileProvider profileProvider = Provider.of<ProfileProvider>(context);

    void _updateNotificationPreference() async {
      String uuid = context.read<AuthenticationService>().getUuid().toString();
      bool success = await profileProvider.updateNotificationPreference(uuid, sendNotifications);

      if (success) {
        FlushbarHelper.createSuccess(
            message: "Updated notification preference!",
            duration: const Duration(seconds: 2))
            .show(context);
      } else {
        FlushbarHelper.createError(
            message: "Failed to update notification preference, try again",
            duration: const Duration(seconds: 2))
            .show(context);
      }
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  const WidgetSpan(child: Icon(Icons.email)),
                  const WidgetSpan(
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.0),
                    ),
                  ),
                  TextSpan(text: context.read<AuthenticationService>().getEmail().toString())
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10.0),
            CheckboxListTile(
              title: const Text("Push Notifications"),
              activeColor: Colors.black,
              checkColor: Colors.white,
              onChanged: (bool? value) {
                setState(() {
                  sendNotifications = value!;
                });
                _updateNotificationPreference();
              }, value: sendNotifications,
            ),
            const SizedBox(height: 25.0),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent
                ),
                onPressed: () async {
                  await context.read<AuthenticationService>().signOut();
                  },
                child: const Text("Sign out")
            ),
          ],
        ),
      ),
    );
  }
}
