import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<bool> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  Future<bool> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  String? getEmail() {
    if (_firebaseAuth.currentUser != null) {
      return _firebaseAuth.currentUser?.email.toString();
    }
    return "";
  }

  String? getUuid() {
    if (_firebaseAuth.currentUser != null) {
      return _firebaseAuth.currentUser?.uid.toString();
    }
    return "";
  }

  Future<String?> getRegistrationToken() {
    return FirebaseMessaging.instance.getToken();
  }
}