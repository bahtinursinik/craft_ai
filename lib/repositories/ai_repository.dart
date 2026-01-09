import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_resource_ai/core/repositories/i_ai_repository.dart';
import 'package:smart_resource_ai/data/models/ai_model.dart';
import 'package:smart_resource_ai/data/services/gemini_service.dart';

class AiRepository implements IAiRepository {

  AiRepository({
    GeminiService? geminiService,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _geminiService = geminiService ?? GeminiService(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;
  final GeminiService _geminiService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<AiModel?> generatePlan({
    required String inputText,
    required bool isFitnessMode,
    required String languageCode,
    Uint8List? imageBytes,
  }) async {
    try {
      final jsonResponse = await _geminiService.generateContent(
        userInput: inputText,
        imageBytes: imageBytes,
        isFitnessMode: isFitnessMode,
        languageCode: languageCode,
      );

      if (jsonResponse != null) {
        return AiModel.fromRawJson(jsonResponse);
      }
      return null;
    } catch (e) {
      debugPrint('AI Plan Oluşturma Hatası: $e');
      rethrow;
    }
  }

  @override
  Future<bool> savePlanToHistory(AiModel plan, bool isFitness) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final planContent = <String, dynamic>{
        'title': plan.title,
        'description': plan.description,
        'difficulty': plan.difficulty,
        'duration': plan.duration,
        'calories': plan.calories,
        'steps': plan.steps,
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .add({
        'title': plan.title,
        'type': isFitness ? 'fitness' : 'food',
        'calories': plan.calories,
        'duration': plan.duration,
        'createdAt': FieldValue.serverTimestamp(),
        'isCompleted': false,
        'content': planContent,
      });

      return true;
    } catch (e) {
      debugPrint('Geçmişe kaydetme hatası: $e');
      return false;
    }
  }
}