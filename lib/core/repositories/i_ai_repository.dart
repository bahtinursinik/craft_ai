import 'dart:typed_data';
import 'package:smart_resource_ai/data/models/ai_model.dart';

abstract class IAiRepository {
  Future<AiModel?> generatePlan({
    required String inputText,
    required bool isFitnessMode,
    required String languageCode,
    Uint8List? imageBytes,
  });

  Future<bool> savePlanToHistory(AiModel plan, bool isFitness);
}
