class Product {
  final String productID;
  final String name;
  final ProductType type;
  final int price;
  final String pictureURL;

  Product({
    required this.productID,
    required this.name,
    required this.type,
    required this.price,
    required this.pictureURL,
  });
}

enum ProductType { drink, food }
