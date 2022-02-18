class Company {
  Company({
    required this.name,
    required this.phone,
    required this.email,
    required this.uid,
    required this.admin,
    required this.worker,
    required this.numShops,
  });

  final String name;
  final String phone;
  final String email;
  final String uid;
  final String admin;
  final String worker;
  final int numShops;

  factory Company.initialData() {
    return Company(
      name: '',
      phone: '',
      email: '',
      uid: '',
      admin: '',
      worker: '',
      numShops: 0,
    );
  }
}
