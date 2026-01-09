
abstract class ILanguageRepository {
  Future<String?> getSavedLanguageCode();

  Future<void> saveLanguageCode(String languageCode);
}