
import 'package:flutter/material.dart';
import 'package:smart_resource_ai/core/repositories/i_auth_repository.dart';
import 'package:smart_resource_ai/core/repositories/i_user_repository.dart';
import 'package:smart_resource_ai/repositories/auth_repository.dart';
import 'package:smart_resource_ai/repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {

  UserViewModel({
    IUserRepository? userRepository,
    IAuthRepository? authRepository,
  })  : _userRepository = userRepository ?? UserRepository(),
        _authRepository = authRepository ?? AuthRepository();
  final IUserRepository _userRepository;
  final IAuthRepository _authRepository;

  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;

  Future<void> fetchUserData() async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final data = await _userRepository.fetchUserData(user.uid);
      if (data != null) {
        _userData = data;
      }
    } catch (e) {
      debugPrint("VM Hata: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteHistoryItem(String documentId) async {
    final user = _authRepository.currentUser;
    if (user == null) return false;

    return await _userRepository.deleteHistoryItem(user.uid, documentId);
    // notifyListeners() gerek yok, StreamBuilder UI'ı günceller.
  }

  Future<void> updateAvatar(String avatarPath) async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    try {
      await _userRepository.updateAvatar(user.uid, avatarPath);

      if (_userData != null) {
        _userData!['avatarPath'] = avatarPath;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("VM Hata: $e");
    }
  }

  Future<bool> saveOnboardingData({
    required String goal,
    required String diet,
    required String equipment,
  }) async {
    final user = _authRepository.currentUser;
    if (user == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final data = {
        'goal': goal,
        'diet': diet,
        'equipment': equipment,
        'isProfileComplete': true,
      };

      final success = await _userRepository.saveOnboardingData(user.uid, data);

      if (success && _userData != null) {
        _userData!.addAll(data);
      }

      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markProfileAsComplete() async {
    final user = _authRepository.currentUser;
    if (user == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final bool success = await _userRepository.markProfileAsComplete(user.uid);

      if (success && _userData != null) {
        _userData!['isProfileComplete'] = true;
      }

      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markHistoryItemAsCompleted(String documentId) async {
    final user = _authRepository.currentUser;
    if (user == null) return false;

    return await _userRepository.markHistoryItemAsCompleted(user.uid, documentId);
  }
}