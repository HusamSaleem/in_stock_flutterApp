class Item {
  final String itemId;
  final String name;
  final String price;
  final String website;
  final bool inStock;

  Item(this.itemId, this.name, this.price, this.website, this.inStock);

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(json['itemId'], json['name'], json['price'], json['website'],
        json['inStock']);
  }

  Map<String, dynamic> toJson() {
    return {
      "itemId": itemId,
      "website": website,
      "name": name,
      "price": price,
      "inStock": inStock,
    };
  }
}
