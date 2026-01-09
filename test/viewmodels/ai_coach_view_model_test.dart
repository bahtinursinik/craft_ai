import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_resource_ai/core/repositories/i_ai_repository.dart';
import 'package:smart_resource_ai/data/models/ai_model.dart';
import 'package:smart_resource_ai/viewmodels/ai_coach_view_model.dart';


class MockAiRepository extends Mock implements IAiRepository {}

void main() {
  late AiCoachViewModel viewModel;
  late MockAiRepository mockRepository;

  setUp(() {
    mockRepository = MockAiRepository();
    viewModel = AiCoachViewModel(aiRepository: mockRepository);
  });

  group('AiCoachViewModel Tests', () {

    test('generateSmartPlan should update currentPlan on success', () async {

      const mockInput = 'I have chicken and rice';
      final mockPlan = AiModel(
        title: 'Chicken Rice',
        description: 'Classic taste',
        calories: '500',
        duration: '20',
        steps: ['Boil', 'Cook'],
        difficulty: 'Easy',
      );


      when(() => mockRepository.generatePlan(
        inputText: mockInput,
        isFitnessMode: false,
        languageCode: any(named: 'languageCode'),
        imageBytes: any(named: 'imageBytes'),
      )).thenAnswer((_) async => mockPlan);

      await viewModel.generateSmartPlan(
          inputText: mockInput,
          isFitnessMode: false,
          languageCode: 'en'
      );

      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
      expect(viewModel.currentPlan, isNotNull);
      expect(viewModel.currentPlan?.title, 'Chicken Rice');
    });

    test('generateSmartPlan should fill errorMessage on failure', () async {
      const mockInput = 'Invalid Input';

      when(() => mockRepository.generatePlan(
        inputText: mockInput,
        isFitnessMode: false,
        languageCode: any(named: 'languageCode'),
        imageBytes: any(named: 'imageBytes'),
      )).thenThrow(Exception('Connection Error'));

      await viewModel.generateSmartPlan(
          inputText: mockInput,
          isFitnessMode: false,
          languageCode: 'en'
      );

      expect(viewModel.isLoading, false);
      expect(viewModel.currentPlan, null);
      expect(viewModel.errorMessage, contains('Connection Error'));
    });
  });
}