import 'dart:math';

import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:in_stock_tracker_new/providers/watchlist_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/item.dart';
import '../providers/authentication_service.dart';

class Watchlist extends StatefulWidget {
  const Watchlist({Key? key}) : super(key: key);

  @override
  _WatchlistState createState() => _WatchlistState();
}

class _WatchlistState extends State<Watchlist> {
  @override
  void initState() {
    super.initState();
    WatchlistProvider watchlistProvider = Provider.of<WatchlistProvider>(context, listen: false);
    String uid = context.read<AuthenticationService>().getUuid().toString();
    watchlistProvider.getWatchlist(uid);
  }

  String? _itemId;
  final _formKey = GlobalKey<FormState>();
  String _websiteDropdownValue = 'Amazon';
  final List<String> _websiteNames = ['Amazon'];

  // Amazon: https://amazon.com/dp/itemID
  // Returns -1 if invalid
  // Amazon id is 10 in length
  String parseAmazonLink(String amazonLink) {
    int dpIndex = amazonLink.indexOf('dp/');
    if (dpIndex == -1 && amazonLink.length != 10) {
      return "-1";
    }
    if (dpIndex == -1) {
      return amazonLink;
    }
    dpIndex += 3;
    int nextSlashIndex = amazonLink.indexOf('/', dpIndex);
    if (nextSlashIndex == -1) {
      return (amazonLink.substring(dpIndex).length == 10)
          ? amazonLink.substring(dpIndex)
          : "-1";
    } else {
      return (amazonLink.substring(dpIndex, nextSlashIndex).length == 10)
          ? amazonLink.substring(dpIndex, nextSlashIndex)
          : "-1";
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    String uid = context.read<AuthenticationService>().getUuid().toString();
    WatchlistProvider watchlistProvider = Provider.of<WatchlistProvider>(context);

    addNewItem() async {
      FlushbarHelper.createInformation(
          message: "Attempting to add new item...",
          duration: const Duration(seconds: 1))
          .show(context);

      final form = _formKey.currentState;
      if (form!.validate()) {
        Item dummyItem = Item(_itemId!, "", "", _websiteDropdownValue, false);
        Map<String, dynamic> response = await watchlistProvider
            .addItemToWatchlist(uid, dummyItem);

        if (response['status']) {
          FlushbarHelper.createSuccess(
              message: "Added new item to watchlist!",
              duration: const Duration(seconds: 1))
              .show(context);
        } else {
          FlushbarHelper.createError(
              title: "Error",
              message: "Failed to add new item",
              duration: const Duration(seconds: 1))
              .show(context);
        }
      }
    }

    // Creates a form for the user to add a new item to their watchlist
    newItemForm() async => showDialog<String>(
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
                      onChanged: (value) => _itemId = parseAmazonLink(value),
                      decoration: const InputDecoration(
                          labelText: "Website Address or ID"),
                      validator: (value) {
                        if (_websiteDropdownValue == 'Amazon') {
                          if (parseAmazonLink(value!) == "-1") {
                            return 'Invalid Amazon Link';
                          }
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField(
                      value: _websiteDropdownValue,
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      onChanged: (String? newValue) {
                        setState(() {
                          _websiteDropdownValue = newValue!;
                        });
                      },
                      items: _websiteNames
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (watchlistProvider.status == Status.Idle) {
                        addNewItem();
                      } else {
                        FlushbarHelper.createInformation(
                            message: "Try again in a few seconds",
                            duration: const Duration(seconds: 3))
                            .show(context);
                      }
                    },
                    child: const Text("Submit"))
              ],
            );
          });
        });

    deleteItem(String itemId) async {
      var response = await watchlistProvider.deleteItemFromWatchlist(
          uid, itemId);

      if (response['status']) {
        FlushbarHelper.createSuccess(
            message: "Successfully deleted!",
            duration: const Duration(seconds: 3))
            .show(context);
      } else {
        FlushbarHelper.createError(
            title: "Error",
            message: "Failed to delete item",
            duration: const Duration(seconds: 3))
            .show(context);
      }
    }

    openConfirmDeletePopup(String itemId) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            "Are you sure you want to remove this item from your watchlist?",
            textAlign: TextAlign.left,
          ),
          actions: [
            TextButton(
              onPressed: () {
                deleteItem(itemId);
                if (watchlistProvider.status == Status.Idle) {
                  deleteItem(itemId);
                } else {
                  Navigator.pop(context);
                  FlushbarHelper.createInformation(
                      message: "Try again in a few seconds",
                      duration: const Duration(seconds: 3))
                      .show(context);
                }
                },
              child: const Text(
                "YES",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18.0,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "NO",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            )
          ],
        ));

    return Scaffold(
      backgroundColor: Colors.black12,
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 15.0,
          ),
          Text((watchlistProvider.list.isNotEmpty)
              ? "Your Watchlist"
              : "Your Watchlist is empty",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 24.0,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w900),
          ),
          Container(
              padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
              color: Colors.black12,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.5
                ),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: watchlistProvider.list.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                        elevation: 0,
                        child: ListTile(
                            horizontalTitleGap: 0.0,
                            isThreeLine: true,
                            title: Text(watchlistProvider.list[index].name
                                .substring(
                                0,
                                min(watchlistProvider.list[index].name.length,
                                    25))),
                            subtitle: Text((watchlistProvider.list[index].inStock
                                ? "In Stock\n"
                                : "Out of Stock\n") +
                                watchlistProvider.list[index].price),
                            leading: IconButton(
                              icon: const Icon(Icons.shopping_cart),
                              color: Colors.green[200],
                              onPressed: () {
                                Uri uri = Uri.parse(getWebsiteLink(
                                    watchlistProvider.list[index].website,
                                    watchlistProvider.list[index].itemId));
                                launchUrl(uri);},
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red[900],
                              onPressed: () => openConfirmDeletePopup(watchlistProvider.list[index].itemId),
                            )
                        )
                    );
                  },
                ),
              )),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
              heroTag: "refresh",
              enableFeedback: true,
              elevation: 8,
              child: const Icon(Icons.refresh),
              backgroundColor: Colors.lightBlue[400],
              onPressed: () async {
                if (watchlistProvider.status == Status.Idle) {
                  FlushbarHelper.createInformation(
                      message: "Refreshing items...",
                      duration: const Duration(seconds: 3))
                      .show(context);
                  await watchlistProvider.refreshWatchlist(uid);
                } else {
                  FlushbarHelper.createInformation(
                      message: "Try again in a few seconds",
                      duration: const Duration(seconds: 3))
                      .show(context);
                }
              }),
          const SizedBox(
            height: 20,
          ),
          FloatingActionButton(
            heroTag: "add",
            enableFeedback: true,
            elevation: 8,
            onPressed: () => newItemForm(),
            child: const Icon(Icons.add, color: Colors.white),
            backgroundColor: Colors.green[600],
          ),
        ],
      ),
    );
  }

  String getWebsiteLink(String website, String itemId) {
    if (website.toLowerCase().compareTo("amazon") == 0) {
      return "https://amazon.com/dp/" + itemId;
    }
    return "";
  }
}
