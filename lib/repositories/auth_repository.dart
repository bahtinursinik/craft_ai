import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_resource_ai/core/repositories/i_auth_repository.dart';

class AuthRepository implements IAuthRepository {

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
  final FirebaseAuth _firebaseAuth;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      // Hata yönetimini bir sonraki adımda global yapacağız, şimdilik fırlatıyoruz.
      rethrow;
    }
  }

  @override
  Future<User?> signUp(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<bool> updatePassword(String newPassword) async {
    try {
      await _firebaseAuth.currentUser?.updatePassword(newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteAccount() async {
    await _firebaseAuth.currentUser?.delete();
  }
}