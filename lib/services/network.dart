const String server = "https://in-stock-tracker-api.herokuapp.com";
const String getAmazonItemInfoLink = "/api/amazon/";
const String watchlistLink = "/api/watchlist";
const String updateUserNotificationsLink = "/api/user/notification";
const String updateUserInfoLink = "/api/user";
const String getUniqueIDLink = "/api/user/uniqueID";

Map<String, String> headers = {
  'Content-type': 'application/json',
  'Accept': 'application/json',
};
