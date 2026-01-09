import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
    );
    return result.user;
  }

  Future<User?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String nickname,
    required String gender,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
    );

    final user = result.user;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'fullName': fullName,
        'nickname': nickname,
        'gender': gender,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
