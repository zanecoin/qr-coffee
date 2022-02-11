class Order {
  String status;
  List items;
  int price;
  String pickUpTime;
  String username;
  String shop;
  String company;
  String orderId;
  String userId;
  String shopId;
  String companyId;
  String day;
  int triggerNum;

  Order({
    required this.status,
    required this.items,
    required this.price,
    required this.pickUpTime,
    required this.username,
    required this.shop,
    required this.company,
    required this.orderId,
    required this.userId,
    required this.shopId,
    required this.companyId,
    required this.day,
    required this.triggerNum,
  });
}
