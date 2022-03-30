class AppUrl {
  static const String serverApi = "http://localhost:8080/api/v1";
  static const String register = serverApi + "/user/register";
  static const String login = serverApi + "/user/login";
  static const String email = serverApi + "/user/email";
  static const String notifications = serverApi + "/user/notifications";

  static const String item = serverApi + "/item";
  static const String watchlist = serverApi + "/watchlist";

  static const Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
}
