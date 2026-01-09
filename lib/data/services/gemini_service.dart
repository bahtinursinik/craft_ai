import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {

  Future<String?> generateContent({
    required String userInput,
    required bool isFitnessMode,
    required String languageCode,
    Uint8List? imageBytes,
  }) async {
    try {
      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-2.0-flash',
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final systemPrompt = _getSystemPrompt(isFitnessMode, languageCode);
      final fullPrompt = '$systemPrompt\n\nUser Input: $userInput';

      final parts = <Part>[TextPart(fullPrompt)];

      if (imageBytes != null) {
        parts.add(InlineDataPart('image/jpeg', imageBytes));
      }

      final response = await model.generateContent([
        Content.multi(parts),
      ]);

      return _cleanJson(response.text);
    } catch (e) {
      debugPrint('Vertex AI Error: $e');
      return null;
    }
  }


  String _getJsonFormatInstruction() {
    return """
    Please provide the response ONLY in valid JSON format.
    Do not add Markdown code blocks (```json).

    Template:
    {
      "title": "String",
      "description": "String",
      "difficulty": "String (Easy/Medium/Hard or Kolay/Orta/Zor)",
      "duration": "String (number only, e.g. '15')",
      "steps": ["String", "String"],
      "calories": "String (number only, e.g. '350')"
    }
    """;
  }

  String _getSystemPrompt(bool isFitnessMode, String lang) {
    String rolePrompt;
    final isTr = lang == 'tr';

    if (isFitnessMode) {
      rolePrompt = isTr
          ? 'Sen uzman bir spor antrenörüsün. Fotoğraftaki veya metindeki ekipmanlara göre evde yapılabilecek bir antrenman programı çıkar. Yanıtın dili TÜRKÇE olmalı.'
          : 'You are an expert fitness coach. Create a home workout program based on the equipment in the photo or text. The response language must be ENGLISH.';
    } else {
      rolePrompt = isTr
          ? 'Sen yaratıcı bir şefsin. Fotoğraftaki veya metindeki malzemelere göre lezzetli bir yemek tarifi çıkar. Yanıtın dili TÜRKÇE olmalı.'
          : 'You are a creative chef. Create a delicious recipe based on the ingredients in the photo or text. The response language must be ENGLISH.';
    }

    return '$rolePrompt\n\n${_getJsonFormatInstruction()}';
  }

  String? _cleanJson(String? text) {
    if (text == null) return null;
    var cleanText = text.replaceAll('```json', '').replaceAll('```', '');
    final startIndex = cleanText.indexOf('{');
    final endIndex = cleanText.lastIndexOf('}');
    if (startIndex != -1 && endIndex != -1) {
      return cleanText.substring(startIndex, endIndex + 1);
    }
    return cleanText.trim();
  }
}