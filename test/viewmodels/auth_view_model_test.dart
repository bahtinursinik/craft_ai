import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_resource_ai/core/repositories/i_auth_repository.dart';
import 'package:smart_resource_ai/viewmodels/auth_view_model.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}
class MockUser extends Mock implements User {}

void main() {
  late AuthViewModel viewModel;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    viewModel = AuthViewModel(authRepository: mockRepo);
  });

  group('AuthViewModel - Sign In Operations', () {

    test('signIn should return true and set isLoading to false on success', () async {
      when(() => mockRepo.signIn(any(), any()))
          .thenAnswer((_) async => MockUser());

      final result = await viewModel.signIn('test@example.com', '123456');

      expect(result, true);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);

      verify(() => mockRepo.signIn('test@example.com', '123456')).called(1);
    });

    test('signIn should return false and populate errorMessage on failure', () async {

      when(() => mockRepo.signIn(any(), any()))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      final result = await viewModel.signIn('wrong@example.com', '123');

      expect(result, false);
      expect(viewModel.isLoading, false);


      expect(viewModel.errorMessage, isNotNull);

    });
  });
}