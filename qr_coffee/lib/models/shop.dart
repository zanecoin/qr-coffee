class Shop {
  Shop({
    required this.uid,
    required this.address,
    required this.coordinates,
    required this.active,
    required this.openingHours,
    required this.city,
    required this.company,
    required this.companyId,
  });

  final String uid;
  final String address;
  final String coordinates;
  final bool active;
  final String openingHours;
  final String city;
  final String company;
  final String companyId;

  factory Shop.initialData() {
    return Shop(
      uid: '',
      address: '',
      coordinates: '',
      active: false,
      openingHours: '',
      city: '',
      company: '',
      companyId: '',
    );
  }
}
