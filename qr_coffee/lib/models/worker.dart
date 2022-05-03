import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';

class Worker extends UserData {
  Worker({
    required this.companyID,
    required String userID,
    UserRole role = UserRole.worker,
  }) : super(role: role, userID: userID);

  final String companyID;

  factory Worker.initialData() {
    return Worker(companyID: '', userID: '');
  }

  updateSoldoutProducts(List<dynamic> soldoutProducts, String shopID) {
    ShopDatabase(companyID: companyID, shopID: shopID).updateSoldoutProducts(soldoutProducts);
  }
}
