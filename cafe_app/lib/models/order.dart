class Order {
  String state;

  List coffee;
  int price;
  String pickUpTime;
  String username;
  String spz;
  String place;

  String orderId;
  String userId;

  Order({
    required this.state,
    required this.coffee,
    required this.price,
    required this.pickUpTime,
    required this.username,
    required this.spz,
    required this.place,
    required this.orderId,
    required this.userId,
  });
}
