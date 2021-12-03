class User {
  final String uid;

  User({required this.uid});

  factory User.initialData() {
    return User(uid: '');
  }
}

class UserData {
  final String uid;
  final String name;
  final String surname;
  final String email;
  final String role;
  final int tokens;
  final String stand;
  final int numOrders;

  UserData({
    required this.uid,
    required this.name,
    required this.surname,
    required this.email,
    required this.role,
    required this.tokens,
    required this.stand,
    required this.numOrders,
  });
}
