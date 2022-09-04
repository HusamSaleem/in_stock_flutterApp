import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import '../models/item.dart';
import '../utils/constants.dart';

enum Status { Idle, GettingItems, AddingItem, DeletingItem, RefreshingItems }

class WatchlistProvider with ChangeNotifier {
  Status _status = Status.Idle;

  List<Item> _list = [];

  List<Item> get list => _list;

  Status get status => _status;

  Future<Map<String, dynamic>> getWatchlist(String uid) async {
    Map<String, Object> result;
    _status = Status.GettingItems;

    // Add in the unique id
    final Uri uri = Uri.parse(Constants.watchlist + "/" + uid);
    Response response = await get(uri, headers: Constants.headers);

    // Successfully got the items
    if (response.statusCode == 200) {
      // Decode the list
      _list = (json.decode(response.body) as List)
          .map((i) => Item.fromJson(i))
          .toList();
      notifyListeners();
      result = {'status': true};
    } else {
      String responseMsg = json.decode(response.body)['message'];
      result = {'status': false, "message": responseMsg};
    }

    _status = Status.Idle;
    return result;
  }

  Future<Map<String, dynamic>> addItemToWatchlist(
      String uid, Item item) async {
    Item addedItem;
    Map<String, Object> result;
    _status = Status.AddingItem;

    final Uri uri = Uri.parse(Constants.watchlist + "/" + uid);
    Response response = await post(uri,
        body: json.encode(item.toJson()), headers: Constants.headers);

    if (response.statusCode == 200) {
      addedItem = Item.fromJson(json.decode(response.body));
      _list.add(addedItem);
      notifyListeners();

      result = {'status': true};
    } else {
      String responseMsg = json.decode(response.body)['message'];
      result = {'status': false, 'message': responseMsg};
    }
    _status = Status.Idle;
    return result;
  }

  Future<Map<String, dynamic>> deleteItemFromWatchlist(
      String uid, String itemId) async {
    Map<String, Object> result;
    _status = Status.DeletingItem;

    final Uri uri = Uri.parse(Constants.watchlist + "/" + uid);
    Map<String, String> request = {"itemId": itemId};
    Response response = await delete(uri,
        body: json.encode(request), headers: Constants.headers);

    if (response.statusCode == 200) {
      Item itemToDelete =
      _list.firstWhere((element) => element.itemId == itemId);
      _list.remove(itemToDelete);
      notifyListeners();
      result = {'status': true};
    } else {
      String responseMsg = json.decode(response.body)['message'];
      result = {'status': true, 'message': responseMsg};
    }
    _status = Status.Idle;
    return result;
  }

  Future<void> refreshWatchlist(String uid) async {
    if (_list.isEmpty) {
      return;
    }
    _status = Status.RefreshingItems;
    List<Item> tempList = _list;
    _list.clear();

    final Uri uri = Uri.parse(Constants.watchlistRefresh + "/" + uid);
    Response response = await get(uri, headers: Constants.headers);

    if (response.statusCode == 200) {
      _list = (json.decode(response.body) as List)
          .map((i) => Item.fromJson(i))
          .toList();
      notifyListeners();
    } else {
      _list.addAll(tempList);
      notifyListeners();
    }
    _status = Status.Idle;
  }
}