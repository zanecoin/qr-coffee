import 'package:qr_coffee/models/order.dart';

Order? getUpdatedOrder(List<Order> orderList, Order order) {
  // PARAMS: [orderList] - all orders form database, [order] - static order
  // RETURN: [result] - updated order from database with same id as the static order
  Order? result;
  for (var item in orderList) {
    if (item.orderId == order.orderId) {
      result = item;
    }
  }
  return result;
}
