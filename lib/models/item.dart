import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Item extends StatefulWidget {
  @override
  State<Item> createState() => _ItemState();

  final String name;
  final String price;
  final bool inStock;
  final String rating;
  final String itemID;
  final String websiteName;
  late final String websiteLink;
  Function(String, String) deleteItemCallback;

  Item(
      {Key? key,
      required this.name,
      required this.rating,
      required this.price,
      required this.inStock,
      required this.websiteName,
      required this.itemID,
      required this.deleteItemCallback})
      : super(key: key) {
    if (websiteName == 'Amazon') {
      websiteLink = _generateAmazonLink(itemID);
    }
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      price: json['price'],
      inStock: json['inStock'],
      rating: json['rating'],
      websiteName: json['website'],
      itemID: json['itemID'],
      deleteItemCallback: (str1, str2) {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "price": price,
      "inStock": inStock,
      "rating": rating,
      "website": websiteName,
      "itemID": itemID
    };
  }

  String _generateAmazonLink(String itemID) {
    return 'https://amazon.com/dp/$itemID';
  }
}

class _ItemState extends State<Item> {
  void deleteItem() {
    widget.deleteItemCallback(widget.itemID, widget.websiteName);
    Navigator.of(context).pop();
  }

  void cancelDeleteItem() {
    Navigator.of(context).pop();
  }

  Future openConfirmDeletePopup() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text(
              "Are you sure you want to remove this item from your watchlist?",
              textAlign: TextAlign.left,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  deleteItem();
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
                  cancelDeleteItem();
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
        horizontalTitleGap: 0.0,
        isThreeLine: true,
        title: Text(widget.name.substring(0, min(widget.name.length, 25))),
        subtitle: Text((widget.inStock ? "In Stock\n" : "Out of Stock\n") +
            '\$${widget.price}'),
        leading: IconButton(
          icon: const Icon(Icons.shopping_cart),
          color: Colors.green[200],
          onPressed: () {
            launch(widget.websiteLink);
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          color: Colors.red[900],
          onPressed: () {
            openConfirmDeletePopup();
          },
        ));
  }
}
