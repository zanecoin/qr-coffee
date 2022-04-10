class Order {
  OrderStatus status;
  Map<dynamic, dynamic> items;
  int price;
  String pickUpTime;
  String username;
  String shop;
  String company;
  String orderID;
  String userID;
  String shopID;
  String companyID;
  String day;

  Order({
    required this.status,
    required this.items,
    required this.price,
    required this.pickUpTime,
    required this.username,
    required this.shop,
    required this.company,
    required this.orderID,
    required this.userID,
    required this.shopID,
    required this.companyID,
    required this.day,
  });
}

enum OrderStatus { pending, waiting, ready, completed, aborted, abandoned, generated, withdraw }
