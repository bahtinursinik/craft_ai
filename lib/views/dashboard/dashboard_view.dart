import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smart_resource_ai/core/constants/app_dimens.dart';
import 'package:smart_resource_ai/core/constants/app_theme.dart';
import 'package:smart_resource_ai/views/history/history_view.dart';
import 'package:smart_resource_ai/views/home/home_view.dart';
import 'package:smart_resource_ai/views/profile/profile_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeView(),
    HistoryView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // ALT MENÜ
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: AppDimens.r20, // ✅ Magic Number yerine AppDimens
              offset: const Offset(0, -5), // Yukarı doğru gölge
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTextStyles.label.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                );
              }
              return AppTextStyles.label.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textLight,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            height: 70,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppColors.primary.withOpacity(0.1),

            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined, color: AppColors.textLight),
                selectedIcon: const Icon(Icons.home, color: AppColors.primary),
                label: l10n.home,
              ),
              NavigationDestination(
                icon: const Icon(Icons.history_outlined, color: AppColors.textLight),
                selectedIcon: const Icon(Icons.history, color: AppColors.primary),
                label: l10n.history,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline, color: AppColors.textLight),
                selectedIcon: const Icon(Icons.person, color: AppColors.primary),
                label: l10n.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}