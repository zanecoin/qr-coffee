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
  final String spz; // state car label
  final String stand;
  final int card;

  UserData({
    required this.uid,
    required this.name,
    required this.surname,
    required this.email,
    required this.role,
    required this.spz,
    required this.stand,
    required this.card,
  });
}
