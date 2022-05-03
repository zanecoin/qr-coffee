class Shop {
  Shop({
    required this.shopID,
    required this.address,
    required this.coordinates,
    required this.openingHours,
    required this.city,
    required this.company,
    required this.companyID,
    required this.soldoutProducts,
  });

  final String shopID;
  final String address;
  final String coordinates;
  final String openingHours;
  final String city;
  final String company;
  final String companyID;
  final List<dynamic> soldoutProducts;

  factory Shop.initialData() {
    return Shop(
      shopID: '',
      address: '',
      coordinates: '',
      openingHours: '',
      city: '',
      company: '',
      companyID: '',
      soldoutProducts: [],
    );
  }
}
