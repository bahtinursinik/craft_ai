import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_resource_ai/core/repositories/i_user_repository.dart';

class UserRepository implements IUserRepository {

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  @override
  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    try {
      final DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc.data()! as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint("Kullanıcı verisi çekilemedi: $e");
      return null;
    }
  }

  @override
  Future<bool> deleteHistoryItem(String uid, String documentId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('history')
          .doc(documentId)
          .delete();
      return true;
    } catch (e) {
      debugPrint("Kayıt silme hatası: $e");
      return false;
    }
  }

  @override
  Future<void> updateAvatar(String uid, String avatarPath) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'avatarPath': avatarPath
      });
    } catch (e) {
      debugPrint("Avatar güncelleme hatası: $e");
      rethrow;
    }
  }

  @override
  Future<bool> saveOnboardingData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).set(
        data,
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      debugPrint("Onboarding kayıt hatası: $e");
      return false;
    }
  }

  @override
  Future<bool> markProfileAsComplete(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'isProfileComplete': true,
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint("Profil tamamlama hatası: $e");
      return false;
    }
  }

  @override
  Future<bool> markHistoryItemAsCompleted(String uid, String documentId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('history')
          .doc(documentId)
          .update({'isCompleted': true});
      return true;
    } catch (e) {
      debugPrint("Plan tamamlama hatası: $e");
      return false;
    }
  }
}