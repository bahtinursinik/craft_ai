import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_resource_ai/core/repositories/i_language_repository.dart';

class LanguageRepository implements ILanguageRepository {
  static const String _storageKey = 'language_code';

  @override
  Future<String?> getSavedLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storageKey);
  }

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, languageCode);
  }
}