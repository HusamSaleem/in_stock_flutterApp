import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:in_stock_tracker/utils/app_url.dart';
import 'package:in_stock_tracker/watchlist/item.dart';

enum Status { Idle, GettingItems, AddingItem, DeletingItem, RefreshingItems }

class WatchlistProvider with ChangeNotifier {
  Status _status = Status.Idle;

  List<Item> _list = [];

  List<Item> get list => _list;

  Status get status => _status;

  Future<Map<String, dynamic>> getWatchlist(String uniqueIdentifier) async {
    var result;
    _status = Status.GettingItems;

    // Add in the unique id
    final Uri uri = Uri.parse(AppUrl.watchlist + "/" + uniqueIdentifier);
    Response response = await get(uri, headers: AppUrl.headers);

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
      String uniqueIdentifier, Item item) async {
    Item addedItem;
    var result;
    _status = Status.AddingItem;

    final Uri uri = Uri.parse(AppUrl.watchlist + "/" + uniqueIdentifier);
    Response response = await post(uri,
        body: json.encode(item.toJson()), headers: AppUrl.headers);

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
      String uniqueIdentifier, Item item) async {
    var result;
    _status = Status.DeletingItem;

    final Uri uri = Uri.parse(AppUrl.watchlist + "/" + uniqueIdentifier);
    Response response = await delete(uri,
        body: json.encode(item.toJson()), headers: AppUrl.headers);

    if (response.statusCode == 200) {
      Item itemToDelete =
          _list.firstWhere((element) => element.itemId == item.itemId);
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

  Future<void> refreshWatchlist() async {
    if (_list.isEmpty) {
      return;
    }
    _status = Status.RefreshingItems;
    List<Item> tempList = List.from(_list);
    removeAll();

    for (Item item in tempList) {
      final Uri uri = Uri.parse(
          AppUrl.item + "?itemId=" + item.itemId + "&website=" + item.website);
      Response response = await get(uri, headers: AppUrl.headers);

      if (response.statusCode == 200) {
        Item updatedItem = Item.fromJson(json.decode(response.body));
        _list.add(updatedItem);
        notifyListeners();
      } else {
        // Add the old item back
        _list.add(item);
        notifyListeners();
      }
    }

    _status = Status.Idle;
  }

  void removeAll() {
    _list.clear();
    notifyListeners();
  }
}
