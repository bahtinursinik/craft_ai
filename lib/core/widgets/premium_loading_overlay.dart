import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smart_resource_ai/core/constants/app_dimens.dart';
import 'package:smart_resource_ai/core/constants/app_theme.dart';

class PremiumLoadingOverlay extends StatefulWidget {

  const PremiumLoadingOverlay({
    required this.isFitnessMode, required this.isLoading, super.key,
  });
  final bool isFitnessMode;
  final bool isLoading;

  @override
  State<PremiumLoadingOverlay> createState() => _PremiumLoadingOverlayState();
}

class _PremiumLoadingOverlayState extends State<PremiumLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true); // İleri geri sar

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    final activeColor = widget.isFitnessMode
        ? AppColors.sportAccent
        : AppColors.foodAccent;

    final activeIcon = widget.isFitnessMode
        ? Icons.fitness_center
        : Icons.restaurant_menu;

    final mainText = widget.isFitnessMode
        ? l10n.creatingPlan
        : l10n.cookingMagic;

    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: 5,
                sigmaY: 5
            ),
            child: Container(
              color: AppColors.background.withOpacity(0.5),
            ),
          ),
        ),

        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
                vertical: AppDimens.p32,
                horizontal: AppDimens.p32
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(AppDimens.r32),
              border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2
              ),
              boxShadow: [
                BoxShadow(
                  color: activeColor.withOpacity(0.25),
                  blurRadius: AppDimens.p32,
                  spreadRadius: 5,
                  offset: AppDimens.cardShadowOffset, // 0,5
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    activeIcon,
                    size: AppDimens.p56,
                    color: activeColor,
                  ),
                ),

                AppDimens.gapH24,

                Text(
                  mainText,
                  style: AppTextStyles.subHeader.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                AppDimens.gapH8,

                Text(
                  l10n.hangTight,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),

                AppDimens.gapH24,

                SizedBox(
                  width: 150,
                  child: LinearProgressIndicator(
                    backgroundColor: activeColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                    borderRadius: BorderRadius.circular(AppDimens.r8),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
