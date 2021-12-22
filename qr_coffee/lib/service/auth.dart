import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/database.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // CREATE USER OBJECT BASED ON FIREBASE USER
  User? _userFromFirebase(auth.User? user) {
    return user == null ? null : User(uid: user.uid);
  }

  // GET USER STREAM
  Stream<User?> get user {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  // REGISTER WITH EMAIL & PASSWORD
  Future registerWithEmailAndPassword(String name, String surname, String email,
      String password, String role) async {
    try {
      auth.UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // CREATE A NEW DOCUMENT FOR THE USER WITH THE UID
      await DatabaseService(uid: credential.user!.uid)
          .updateUserData(name, surname, email, role, 0, '', 0);
      return '';
    } on auth.FirebaseAuthException catch (error) {
      return error.message;
    }
  }

  // SIGN IN WITH EMAIL & PASSWORD
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return '';
    } on auth.FirebaseAuthException catch (error) {
      return error.message;
    }
  }

  // SIGN OUT
  Future userSignOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
