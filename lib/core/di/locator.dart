import 'package:get_it/get_it.dart';
import 'package:smart_resource_ai/core/repositories/i_ai_repository.dart';
import 'package:smart_resource_ai/core/repositories/i_auth_repository.dart';
import 'package:smart_resource_ai/core/repositories/i_language_repository.dart';
import 'package:smart_resource_ai/core/repositories/i_user_repository.dart';
import 'package:smart_resource_ai/repositories/ai_repository.dart';
import 'package:smart_resource_ai/repositories/auth_repository.dart';
import 'package:smart_resource_ai/repositories/language_repository.dart';
import 'package:smart_resource_ai/repositories/user_repository.dart';
import 'package:smart_resource_ai/viewmodels/ai_coach_view_model.dart';
import 'package:smart_resource_ai/viewmodels/auth_view_model.dart';
import 'package:smart_resource_ai/viewmodels/language_view_model.dart';
import 'package:smart_resource_ai/viewmodels/user_view_model.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {


  locator..registerLazySingleton<IAuthRepository>(AuthRepository.new)
  ..registerLazySingleton<IUserRepository>(UserRepository.new)
  ..registerLazySingleton<IAiRepository>(AiRepository.new)
  ..registerLazySingleton<ILanguageRepository>(LanguageRepository.new)


  ..registerFactory<AuthViewModel>(
        () => AuthViewModel(authRepository: locator<IAuthRepository>()),
  )

  ..registerFactory<UserViewModel>(
        () => UserViewModel(
      userRepository: locator<IUserRepository>(),
      authRepository: locator<IAuthRepository>(),
    ),
  )

  ..registerFactory<AiCoachViewModel>(
        () => AiCoachViewModel(aiRepository: locator<IAiRepository>()),
  )

  ..registerFactory<LanguageViewModel>(
        () => LanguageViewModel(repository: locator<ILanguageRepository>()),
  );
}
