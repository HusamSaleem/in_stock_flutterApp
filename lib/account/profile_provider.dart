import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:in_stock_tracker/utils/app_url.dart';

class ProfileProvider with ChangeNotifier {
  Future<Map<String, dynamic>> updateEmail(
      String uniqueIdentifier, String newEmail) async {
    var result;

    // Add in the unique id
    final Uri uri = Uri.parse(
        AppUrl.email + "/" + uniqueIdentifier + "?newEmail=" + newEmail);
    Response response = await put(uri, headers: AppUrl.headers);

    // Successfully updated email
    if (response.statusCode == 200) {
      result = {'status': true};
    } else {
      result = {'status': false};
    }

    return result;
  }

  Future<Map<String, dynamic>> updateNotificationPreference(
      String uniqueIdentifier, bool notifyByEmail) async {
    var result;
    // Add in the unique id
    final Uri uri = Uri.parse(AppUrl.notifications +
        "/" +
        uniqueIdentifier +
        "?notifyByEmail=" +
        notifyByEmail.toString());
    Response response = await put(uri, headers: AppUrl.headers);

    // Successfully updated email
    if (response.statusCode == 200) {
      result = {'status': true};
    } else {
      result = {'status': false};
    }

    return result;
  }
}
