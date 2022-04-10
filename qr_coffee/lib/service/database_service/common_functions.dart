import 'package:qr_coffee/models/order.dart';

class CommonDatabaseFunctions {
  OrderStatus getEnumStatus(String strStatus) {
    switch (strStatus) {
      case 'PENDING':
        return OrderStatus.pending;
      case 'WAITING':
        return OrderStatus.waiting;
      case 'READY':
        return OrderStatus.ready;
      case 'WITHDRAW':
        return OrderStatus.withdraw;
      case 'COMPLETED':
        return OrderStatus.completed;
      case 'ABORTED':
        return OrderStatus.aborted;
      case 'ABANDONED':
        return OrderStatus.abandoned;
      case 'GENERATED':
        return OrderStatus.generated;
      default:
        return OrderStatus.pending;
    }
  }

  String getStrStatus(OrderStatus strStatus) {
    switch (strStatus) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.waiting:
        return 'WAITING';
      case OrderStatus.ready:
        return 'READY';
      case OrderStatus.withdraw:
        return 'WITHDRAW';
      case OrderStatus.completed:
        return 'COMPLETED';
      case OrderStatus.aborted:
        return 'ABORTED';
      case OrderStatus.abandoned:
        return 'ABANDONED';
      case OrderStatus.generated:
        return 'GENERATED';
      default:
        return 'PENDING';
    }
  }
}
