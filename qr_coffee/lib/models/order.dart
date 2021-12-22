class Order {
  String status;

  List items;
  int price;
  String pickUpTime;
  String username;
  String place;
  String orderId;
  String userId;
  String day;
  int triggerNum;

  Order({
    required this.status,
    required this.items,
    required this.price,
    required this.pickUpTime,
    required this.username,
    required this.place,
    required this.orderId,
    required this.userId,
    required this.day,
    required this.triggerNum,
  });
}
