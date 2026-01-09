abstract class IUserRepository {
  Future<Map<String, dynamic>?> fetchUserData(String uid);

  Future<bool> deleteHistoryItem(String uid, String documentId);

  Future<void> updateAvatar(String uid, String avatarPath);

  Future<bool> saveOnboardingData(String uid, Map<String, dynamic> data);

  Future<bool> markProfileAsComplete(String uid);

  Future<bool> markHistoryItemAsCompleted(String uid, String documentId);
}