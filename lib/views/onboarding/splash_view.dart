import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_resource_ai/core/constants/app_dimens.dart';
import 'package:smart_resource_ai/core/constants/app_theme.dart';
import 'package:smart_resource_ai/core/gen/assets.gen.dart';
import 'package:smart_resource_ai/main.dart';
import 'package:smart_resource_ai/views/onboarding/onboarding_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              Assets.animations.splashAnim,
              width: size.width * 0.8,
              fit: BoxFit.contain,
              controller: _controller,
              onLoaded: (composition) {
                _controller
                  ..duration = composition.duration
                  ..forward().whenComplete(_navigateToNextScreen);
              },
            ),

            const SizedBox(height: AppDimens.p48),

            Text(
              l10n.appName,
              style: AppTextStyles.header.copyWith(
                color: AppColors.primary,
                fontSize: 26,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (!mounted) return;

    final nextScreen = seenOnboarding ? const AuthWrapper() : const OnboardingView();

    await Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => nextScreen,
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }
}
