import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';

class Admin extends UserData {
  Admin({
    required this.companyID,
    required String userID,
    UserRole role = UserRole.admin,
  }) : super(role: role, userID: userID);

  final String companyID;

  updateProductData() {}

  addShop(String address, String city, String openingHours, String company) {
    ShopDatabase(companyID: companyID).addShop(address, city, openingHours, company);
  }

  updateShopData(String shopID, String address, String coordinates, String city,
      String openingHours, String company) {
    ShopDatabase(shopID: shopID)
        .updateShopData(shopID, address, coordinates, city, openingHours, company);
  }

  deleteShop(String shopID) {
    ShopDatabase(shopID: shopID).deleteShop(shopID);
  }

  updateCompanyData(String name, String phone, String email) {
    CompanyDatabase(companyID: this.companyID).updateCompanyData(name, phone, email);
  }

  updateCompanyShopNum(int shopNum) {
    CompanyDatabase(companyID: this.companyID).updateCompanyShopNum(shopNum);
  }

  factory Admin.initialData() {
    return Admin(companyID: '', userID: '');
  }
}
