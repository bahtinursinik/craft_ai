import 'package:flutter_test/flutter_test.dart';
import 'package:smart_resource_ai/data/models/ai_model.dart';

void main() {
  group('AiModel Tests', () {

    test('fromJson should parse valid JSON correctly', () {
      final json = <String, dynamic>{
        'title': 'Protein Bomb',
        'description': 'Ideal for muscle building.',
        'difficulty': 'Medium',
        'duration': '25',
        'steps': ['Crack eggs', 'Whisk', 'Cook'],
        'calories': '350'
      };

      final model = AiModel.fromJson(json);

      expect(model.title, 'Protein Bomb');
      expect(model.description, 'Ideal for muscle building.');
      expect(model.difficulty, 'Medium');
      expect(model.duration, '25');
      expect(model.calories, '350');
      expect(model.steps.length, 3);
      expect(model.steps.first, 'Crack eggs');
    });

    test('should convert numeric values (Int/Double) to String', () {
      final json = <String, dynamic>{
        'title': 'Test Plan',
        'description': 'Testing types',
        'difficulty': 'Easy',
        'duration': 45,
        'calories': 500.5,
        'steps': []
      };

      final model = AiModel.fromJson(json);

      expect(model.duration, '45');
      expect(model.calories, '500.5');
    });


    test('should assign default English values when data is null', () {
      final emptyJson = <String, dynamic>{};

      final model = AiModel.fromJson(emptyJson);

      expect(model.title, 'Untitled Plan');
      expect(model.description, 'No description.');
      expect(model.difficulty, 'Unknown');
      expect(model.duration, '15');
      expect(model.calories, '0');
      expect(model.steps, isEmpty);
    });

    test('fromRawJson should parse String data correctly', () {
      const rawJson = '{"title": "String Test", "duration": "10"}';

      final model = AiModel.fromRawJson(rawJson);

      expect(model.title, 'String Test');
      expect(model.duration, '10');
      expect(model.calories, '0');
    });
  });
}