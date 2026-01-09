import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_resource_ai/core/repositories/i_auth_repository.dart';
import 'package:smart_resource_ai/data/services/auth_service.dart';
import 'package:smart_resource_ai/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {


  AuthViewModel({IAuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();
  final IAuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  set errorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  Stream<User?> get authStateChanges => _authRepository.authStateChanges;

  User? get currentUser => _authRepository.currentUser;

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authRepository.signIn(email, password);

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      return false;
    } catch (e) {
      _errorMessage = "Bir hata oluştu: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- KAYIT OL ---
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String nickname,
    required String gender,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 1. Auth İşlemi (Repository üzerinden)
      User? user = await _authRepository.signUp(email, password);

      if (user != null) {
        // 2. Firestore İşlemi (Bunu da UserRepository'ye taşıyacağız ama şimdilik burada kalsın)
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email,
          'fullName': fullName,
          'nickname': nickname,
          'gender': gender,
          'createdAt': FieldValue.serverTimestamp(),
          'isProfileComplete': false,
        });
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      return false;
    } catch (e) {
      _errorMessage = "Kayıt sırasında hata: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- ÇIKIŞ YAP ---
  Future<void> signOut() async {
    await _authRepository.signOut();
    notifyListeners();
  }

  // --- ŞİFRE GÜNCELLE ---
  Future<bool> updatePassword(String newPassword) async {
    return await _authRepository.updatePassword(newPassword);
  }

  // --- HESAP SİL ---
  Future<void> deleteAccount() async {
    await _authRepository.deleteAccount();
  }

  // Hata Mesajlarını Türkçeleştirme (Yardımcı metod)
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Böyle bir kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Şifre hatalı.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'invalid-email':
        return 'Geçersiz e-posta formatı.';
      case 'weak-password':
        return 'Şifre çok zayıf.';
      default:
        return 'Giriş başarısız. Lütfen tekrar deneyin.';
    }
  }
}