class Constants {
  static const String serverApi =
      "https://in-stock-tracker-api-new.herokuapp.com/api/v1";
  static const String notification = serverApi + "/user/notification";
  static const String token = serverApi + "/user/token";
  static const String user = serverApi + "/user";

  static const String item = serverApi + "/item";
  static const String watchlist = serverApi + "/watchlist";
  static const String watchlistRefresh = serverApi + "/watchlist/refresh";

  static const Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
}