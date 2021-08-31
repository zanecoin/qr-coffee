import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cafe_app/models/user.dart';
import 'package:cafe_app/service/database.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // create user object based on Firebase user
  User? _userFromFirebase(auth.User? user) {
    return user == null ? null : User(uid: user.uid);
  }

  // get user stream
  Stream<User?> get user {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  // register with email & password
  Future registerWithEmailAndPassword(String name, String surname, String email,
      String password, String role) async {
    try {
      auth.UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // create a new document for the user with the uid
      await DatabaseService(uid: credential.user!.uid)
          .updateUserData(name, surname, email, role, '', '');
      return '';
    } on auth.FirebaseAuthException catch (error) {
      return error.message;
    }
  }

  // sign in with email & password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      auth.UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return '';
    } on auth.FirebaseAuthException catch (error) {
      return error.message;
    }
  }

  // sign out
  Future userSignOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
