import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Create user object based on firebase user.
  User? _userFromFirebase(auth.User? user) {
    return user == null ? null : User(uid: user.uid);
  }

  // Get user stream.
  Stream<User?> get user {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  // Register with email & password.
  Future registerWithEmailAndPassword(
      String name, String surname, String email, String password) async {
    try {
      auth.UserCredential credential =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Create a new document for the user with the uid.
      await UserDatabase(uid: credential.user!.uid)
          .updateUserData(name, surname, email, 'customer', 0, false, 0, '');
      return '';
    } on auth.FirebaseAuthException catch (error) {
      return error.message;
    }
  }

  // Sign in with email & password.
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return '';
    } on auth.FirebaseAuthException catch (error) {
      return error.message;
    }
  }

  // Sign out.
  Future userSignOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
