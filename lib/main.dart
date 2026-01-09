import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smart_resource_ai/core/constants/app_theme.dart';
import 'package:smart_resource_ai/core/di/locator.dart';
import 'package:smart_resource_ai/core/repositories/i_user_repository.dart';
import 'package:smart_resource_ai/data/services/notification_service.dart';
import 'package:smart_resource_ai/viewmodels/ai_coach_view_model.dart';
import 'package:smart_resource_ai/viewmodels/auth_view_model.dart';
import 'package:smart_resource_ai/viewmodels/language_view_model.dart';
import 'package:smart_resource_ai/viewmodels/user_view_model.dart';
import 'package:smart_resource_ai/views/auth/auth_view.dart';
import 'package:smart_resource_ai/views/dashboard/dashboard_view.dart';
import 'package:smart_resource_ai/views/onboarding/preferences_view.dart';
import 'package:smart_resource_ai/views/onboarding/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locator<AiCoachViewModel>()),
        ChangeNotifierProvider(create: (_) => locator<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => locator<UserViewModel>()),
        ChangeNotifierProvider(create: (_) => locator<LanguageViewModel>()),
      ],
      child: Consumer<LanguageViewModel>(
          builder: (context, languageViewModel, child) {
            return MaterialApp(
              title: 'Craft AI',
              debugShowCheckedModeBanner: false,

              locale: languageViewModel.currentLocale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,

              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primary,
                  primary: AppColors.primary,
                  background: AppColors.background,
                ),
                useMaterial3: true,
                scaffoldBackgroundColor: AppColors.background,
                fontFamily: 'Poppins',
              ),

              home: const SplashView(),
            );
          }
      ),
    );
  }
}


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authViewModel.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (authSnapshot.hasData && authSnapshot.data != null) {
          final currentUser = authSnapshot.data!;

          return FutureBuilder<Map<String, dynamic>?>(
            future: locator<IUserRepository>().fetchUserData(currentUser.uid),
            builder: (context, userSnapshot) {

              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data != null) {
                final userData = userSnapshot.data!;

                final isProfileComplete = (userData['isProfileComplete'] as bool?) ?? false;

                if (isProfileComplete) {
                  return const DashboardView();
                } else {
                  return const PreferencesView();
                }
              }

              return const PreferencesView();
            },
          );
        }

        return const AuthView();
      },
    );
  }
}