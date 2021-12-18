import 'dart:convert';

import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_stock_tracker/models/item.dart';
import 'package:in_stock_tracker/services/network.dart';
import 'package:in_stock_tracker/services/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  late TextEditingController controller = TextEditingController();
  String dropdownValue = 'Amazon'; // Default website
  List<String> websiteNames = ['Amazon'];
  List<Item> watchList = [];
  final _formKey = GlobalKey<FormState>();
  late AnimationController loadingIconController;

  @override
  void initState() {
    super.initState();
    loadWatchlist();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<String?> newItemForm() => showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add new item to watchlist"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(
                        labelText: "Website Address or ID"),
                    validator: (websiteLink) {
                      if (dropdownValue == 'Amazon') {
                        if (parseAmazonLink(websiteLink!) == "-1") {
                          return 'Invalid Amazon Link';
                        }
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField(
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    items: websiteNames
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                          value: value, child: Text(value));
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.green[600]),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (user.email == null && user.phoneNumber == null) {
                        FlushbarHelper.createError(
                                message:
                                    'You need at least a email or phone number saved to add a new item',
                                title: 'Error',
                                duration: const Duration(seconds: 2))
                            .show(context);
                      } else {
                        FlushbarHelper.createInformation(
                                message: 'Attempting to add new item',
                                duration: const Duration(seconds: 3))
                            .show(context);
                        submitNewItem();
                      }
                    }
                  },
                  child: const Text("Submit"))
            ],
          );
        });
      });

  Future<void> saveWatchlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('watchlist', jsonEncode(watchList));
  }

  Future<void> loadWatchlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? watchlistJson = prefs.getString('watchlist');

    if (watchlistJson != null) {
      final List temp = json.decode(watchlistJson);
      setState(() {
        watchList = temp.map((data) => Item.fromJson(data)).toList();
      });
    }
  }

  Future<void> submitNewItem() async {
    if (dropdownValue == 'Amazon') {
      String itemID = parseAmazonLink(controller.text);
      if (itemID != "-1") {
        await joinWatchList(dropdownValue, itemID, 0);
      } else {
        FlushbarHelper.createError(
                message: 'Invalid link for $dropdownValue}',
                title: 'error',
                duration: const Duration(seconds: 2))
            .show(context);
      }
    }

    Navigator.of(context).pop(controller.text);
    controller.clear();
  }

  Future deleteItem(String itemID, String website) async {
    var body = json.encode(
        {"uniqueID": user.uniqueID, "itemID": itemID, "website": website});

    final response = await http.delete(Uri.parse('$server$watchlistLink'),
        body: body, headers: headers);

    if (response.statusCode == 200) {
      Item? itemToRemove;
      for (Item item in watchList) {
        if (item.itemID == itemID) {
          itemToRemove = item;
        }
      }

      setState(() {
        watchList = List.from(watchList)..remove(itemToRemove);
      });
      saveWatchlist();

      FlushbarHelper.createSuccess(
              message: 'Removed item!',
              title: 'Success',
              duration: const Duration(seconds: 2))
          .show(context);
    } else {
      FlushbarHelper.createError(
              message: 'Failed to remove item, try again',
              title: 'Error',
              duration: const Duration(seconds: 2))
          .show(context);
    }
  }

  Future joinWatchList(String websiteName, String itemID, int retries) async {
    var possibleDuplicates =
        watchList.where((element) => element.itemID == itemID).toList();
    if (possibleDuplicates.length > 0) {
      await FlushbarHelper.createError(
              message: 'You already have that item on your watchlist!',
              title: 'Error',
              duration: const Duration(seconds: 2))
          .show(context);
      return;
    }

    if (retries == 3) {
      FlushbarHelper.createError(
              message: 'Failed to add item to watch list, try again',
              title: 'Error',
              duration: const Duration(seconds: 2))
          .show(context);
      return;
    }

    var body = json.encode({
      "itemID": itemID,
      "website": websiteName,
      "email": (user.email == null) ? "" : user.email,
      "number": (user.phoneNumber == null) ? "" : user.phoneNumber
    });

    final response = await http.post(Uri.parse('$server$watchlistLink'),
        body: body, headers: headers);

    if (response.statusCode == 200) {
      Item newItem = Item.fromJson(jsonDecode(response.body));
      newItem.deleteItemCallback = (id, name) {
        deleteItem(id, name);
      };

      setState(() {
        watchList = [...watchList, newItem];
      });
      saveWatchlist();
      FlushbarHelper.createSuccess(
              message: 'Added new item to your watchlist!',
              title: 'Success',
              duration: const Duration(seconds: 2))
          .show(context);
    } else {
      if (response.body == "Failed to get items, Try again") {
        joinWatchList(websiteName, itemID, retries + 1);
      }
    }
  }

  Future<Item?> getItem(String website, String itemID) async {
    if (website == 'Amazon') {
      final response = await http.get(
          Uri.parse('$server$getAmazonItemInfoLink$itemID'),
          headers: headers);

      if (response.statusCode == 200) {
        return Item.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    }
  }

  Future refreshWatchList() async {
    if (watchList.length == 0) {
      return;
    }
    FlushbarHelper.createInformation(
            message: 'This may take a while', duration: Duration(seconds: 3))
        .show(context);

    List<Item> temp = List.from(watchList);
    setState(() {
      watchList = [];
    });

    for (Item item in temp) {
      Item? updatedItem = await getItem(item.websiteName, item.itemID);

      if (updatedItem != null) {
        setState(() {
          updatedItem.deleteItemCallback = (id, name) {
            deleteItem(id, name);
          };
          watchList = [...watchList, updatedItem];
        });
      } else {
        setState(() {
          watchList = [...watchList, item];
        });
      }
    }
    saveWatchlist();

    FlushbarHelper.createSuccess(
            message: 'Refreshed items!',
            title: 'Success',
            duration: Duration(seconds: 2))
        .show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 15.0,
          ),
          Text(
            (watchList.isNotEmpty)
                ? "Your Watchlist"
                : "Your Watchlist is Empty",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 24.0,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w900),
          ),
          Container(
              padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
              color: Colors.black12,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: watchList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(elevation: 0, child: watchList[index]);
                },
              )),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
              enableFeedback: true,
              elevation: 16,
              child: const Icon(Icons.refresh),
              backgroundColor: Colors.lightBlue[400],
              onPressed: () {
                refreshWatchList();
              }),
          SizedBox(
            height: 20,
          ),
          FloatingActionButton(
            enableFeedback: true,
            elevation: 16,
            onPressed: () {
              newItemForm();
            },
            child: const Icon(Icons.add, color: Colors.white),
            backgroundColor: Colors.green[600],
          ),
        ],
      ),
    );
  }
}
