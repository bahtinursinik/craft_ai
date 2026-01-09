import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_resource_ai/core/repositories/i_language_repository.dart';
import 'package:smart_resource_ai/repositories/language_repository.dart';

class LanguageViewModel extends ChangeNotifier {

  LanguageViewModel({ILanguageRepository? repository})
      : _repository = repository ?? LanguageRepository() {
    _loadLanguage();
  }
  final ILanguageRepository _repository;

  Locale _currentLocale = const Locale('tr');

  Locale get currentLocale => _currentLocale;

  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale == locale) return;

    _currentLocale = locale;
    notifyListeners();

    await _repository.saveLanguageCode(locale.languageCode);
  }

  Future<void> _loadLanguage() async {
    final String? languageCode = await _repository.getSavedLanguageCode();

    if (languageCode != null) {
      _currentLocale = Locale(languageCode);
      notifyListeners();
    }
  }
}