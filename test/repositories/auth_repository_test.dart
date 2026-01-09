import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_resource_ai/repositories/auth_repository.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  late AuthRepository repository;
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    repository = AuthRepository(firebaseAuth: mockFirebaseAuth);
  });

  test('signIn should call FirebaseAuth.signInWithEmailAndPassword and return User', () async {
    final mockCredential = MockUserCredential();
    final mockUser = MockUser();
    const email = 'test@example.com';
    const password = 'password123';

    when(() => mockCredential.user).thenReturn(mockUser);

    when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
    )).thenAnswer((_) async => mockCredential);

    final result = await repository.signIn(email, password);

    expect(result, mockUser);

    verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
    )).called(1);
  });
}