import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthRepository {
  Stream<User?> get authStateChanges;

  User? get currentUser;

  Future<User?> signIn(String email, String password);

  Future<User?> signUp(String email, String password);

  Future<void> signOut();

  Future<bool> updatePassword(String newPassword);

  Future<void> deleteAccount();
}