import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_resource_ai/core/repositories/i_ai_repository.dart';
import 'package:smart_resource_ai/data/models/ai_model.dart';
import 'package:smart_resource_ai/repositories/ai_repository.dart';

class AiCoachViewModel extends ChangeNotifier {

  AiCoachViewModel({IAiRepository? aiRepository})
      : _aiRepository = aiRepository ?? AiRepository();
  final IAiRepository _aiRepository;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  String? _errorMessage;
  AiModel? _currentPlan;
  Uint8List? _selectedImageBytes;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AiModel? get currentPlan => _currentPlan;
  Uint8List? get selectedImageBytes => _selectedImageBytes;

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 70,
      );

      if (image != null) {
        _selectedImageBytes = await image.readAsBytes();
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Resim seçilirken hata oluştu: $e";
      notifyListeners();
    }
  }

  void clearImage() {
    _selectedImageBytes = null;
    notifyListeners();
  }

  Future<void> generateSmartPlan({
    required String inputText,
    required bool isFitnessMode,
    required String languageCode,
  }) async {
    if (inputText.trim().isEmpty && _selectedImageBytes == null) {
      _errorMessage = 'Lütfen en az bir malzeme/ekipman yazın veya fotoğraf yükleyin.';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      _currentPlan = null;
      notifyListeners();

      _currentPlan = await _aiRepository.generatePlan(
        inputText: inputText,
        isFitnessMode: isFitnessMode,
        imageBytes: _selectedImageBytes,
        languageCode: languageCode,
      );

      if (_currentPlan == null) {
        _errorMessage = "AI anlamlı bir plan üretemedi. Lütfen tekrar deneyin.";
      }
    } catch (e) {
      _errorMessage = "Bir hata oluştu: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveCurrentPlanToHistory({required bool isFitness}) async {
    if (_currentPlan == null) return false;

    return await _aiRepository.savePlanToHistory(_currentPlan!, isFitness);
  }
}