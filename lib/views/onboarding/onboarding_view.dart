import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_resource_ai/core/constants/app_dimens.dart';
import 'package:smart_resource_ai/core/constants/app_theme.dart';
import 'package:smart_resource_ai/main.dart';


class _OnboardingItem {

  _OnboardingItem({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
  });
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (mounted) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final pages = <_OnboardingItem>[
      _OnboardingItem(
        title: l10n.onboardingTitle1,
        desc: l10n.onboardingDesc1,
        icon: Icons.psychology_alt_rounded,
        color: AppColors.primary,
      ),
      _OnboardingItem(
        title: l10n.onboardingTitle2,
        desc: l10n.onboardingDesc2,
        icon: Icons.layers_outlined,
        color: AppColors.foodAccent, // ✅ Renk paletinden
      ),
      _OnboardingItem(
        title: l10n.onboardingTitle3,
        desc: l10n.onboardingDesc3,
        icon: Icons.rocket_launch_rounded,
        color: AppColors.sportAccent, // ✅ Renk paletinden
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (int page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) {
              final item = pages[index];
              return _buildPageContent(
                title: item.title,
                desc: item.desc,
                icon: item.icon,
                color: item.color,
              );
            },
          ),

          Positioned(
            bottom: AppDimens.p48,
            left: AppDimens.p24,
            right: AppDimens.p24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    pages.length,
                        _buildDot,
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == pages.length - 1) {
                      _finishOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.p24,
                        vertical: AppDimens.p12
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.r12)
                    ),
                  ),
                  child: Text(
                    _currentPage == pages.length - 1 ? l10n.letsStart : l10n.next,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 60,
            right: AppDimens.p20,
            child: TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                  l10n.skip,
                  style: const TextStyle(
                      color: AppColors.textGray,
                      fontWeight: FontWeight.bold
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent({
    required String title,
    required String desc,
    required IconData icon,
    required Color color
  }) {
    return Padding(
      padding: AppDimens.all32,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 100, color: color),
          ),
          const SizedBox(height: 60),
          Text(
              title,
              style: AppTextStyles.header.copyWith(fontSize: 28),
              textAlign: TextAlign.center
          ),
          const SizedBox(height: AppDimens.p20),
          Text(
              desc,
              style: AppTextStyles.body.copyWith(
                  fontSize: 16,
                  color: AppColors.textGray
              ),
              textAlign: TextAlign.center
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: AppDimens.p8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}