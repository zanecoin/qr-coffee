class Company {
  Company({
    required this.companyID,
    required this.adminID,
    required this.workerID,
    required this.name,
    required this.phone,
    required this.email,
    required this.numShops,
  });

  final String companyID;
  final String adminID;
  final String workerID;
  final String name;
  final String phone;
  final String email;
  final int numShops;

  factory Company.initialData() {
    return Company(
      companyID: '',
      adminID: '',
      workerID: '',
      name: '',
      phone: '',
      email: '',
      numShops: 0,
    );
  }
}
