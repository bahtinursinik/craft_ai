import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_resource_ai/core/constants/app_dimens.dart';
import 'package:smart_resource_ai/core/constants/app_theme.dart';
import 'package:smart_resource_ai/core/widgets/common_widgets.dart';
import 'package:smart_resource_ai/core/widgets/premium_loading_overlay.dart';
import 'package:smart_resource_ai/viewmodels/ai_coach_view_model.dart';
import 'package:smart_resource_ai/viewmodels/user_view_model.dart';
import 'package:smart_resource_ai/views/results/result_view.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _textController = TextEditingController();
  bool isFitnessMode = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<UserViewModel>(context, listen: false).fetchUserData()
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Color get activeColor => isFitnessMode ? AppColors.sportAccent : AppColors.foodAccent;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AiCoachViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context);
    final userData = userViewModel.userData;

    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    var nickname = (userData?['nickname'] as String?) ?? l10n.guest;
    if (nickname.isNotEmpty) {
      nickname = nickname[0].toUpperCase() + nickname.substring(1);
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: activeColor.withOpacity(0.03),
        extendBodyBehindAppBar: true,

        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  '${l10n.hello} ',
                  style: AppTextStyles.subHeader.copyWith(
                      fontWeight: FontWeight.normal,
                      color: AppColors.textGray
                  )
              ),
              Text(
                  '$nickname 👋',
                  style: AppTextStyles.subHeader.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark
                  )
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),

        body: Stack(
          children: [
            Stack(
              children: [
                Positioned(
                  right: -50,
                  top: size.height * 0.20,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, anim) => RotationTransition(
                        turns: anim,
                        child: FadeTransition(opacity: anim, child: child)
                    ),
                    child: Icon(
                      isFitnessMode ? Icons.fitness_center_rounded : Icons.restaurant_menu_rounded,
                      key: ValueKey(isFitnessMode),
                      size: 300,
                      color: activeColor.withOpacity(0.05),
                    ),
                  ),
                ),

                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: 110,
                    left: AppDimens.p24,
                    right: AppDimens.p24,
                    bottom: AppDimens.p48,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      _buildSoftSegmentedControl(l10n),
                      const SizedBox(height: AppDimens.p32),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          key: ValueKey(isFitnessMode),
                          children: [
                            Text(
                                isFitnessMode ? l10n.readyQuestion : l10n.hungryQuestion,
                                style: AppTextStyles.label.copyWith(
                                    color: activeColor,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5
                                )
                            ),
                            const SizedBox(height: AppDimens.p8),
                            Text(
                                isFitnessMode ? l10n.tellEquipment : l10n.tellIngredients,
                                style: AppTextStyles.header.copyWith(fontSize: 28),
                                textAlign: TextAlign.center
                            ),
                            const SizedBox(height: AppDimens.p12),
                            Text(
                                isFitnessMode ? l10n.fitnessDesc : l10n.foodDesc,
                                style: AppTextStyles.body.copyWith(height: 1.5),
                                textAlign: TextAlign.center
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimens.p32),

                      _buildHeroInputArea(viewModel, l10n),
                      const SizedBox(height: AppDimens.p24),
                      if (viewModel.selectedImageBytes != null) _buildImagePreview(viewModel),
                      const SizedBox(height: AppDimens.p32),

                      CustomButton(
                        text: l10n.startMagic,
                        color: activeColor,
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          final currentLocale = Localizations.localeOf(context).languageCode;
                          await viewModel.generateSmartPlan(
                            inputText: _textController.text,
                            isFitnessMode: isFitnessMode,
                            languageCode: currentLocale,
                          );

                          if (context.mounted) {
                            if (viewModel.currentPlan != null) {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ResultView(
                                        isFitnessMode: isFitnessMode,
                                      )
                                  )
                              );
                            } else if (viewModel.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(viewModel.errorMessage!),
                                      backgroundColor: AppColors.error
                                  )
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            PremiumLoadingOverlay(
              isFitnessMode: isFitnessMode,
              isLoading: viewModel.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoftSegmentedControl(AppLocalizations l10n) {
    return Container(
      height: 55,
      padding: const EdgeInsets.all(AppDimens.p4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(30), // Pill shape için sabit kalabilir
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double itemWidth = (constraints.maxWidth - 8) / 2;

          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                alignment: isFitnessMode ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  width: itemWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  _buildSoftOption(l10n.fitness, Icons.fitness_center_rounded, true),
                  _buildSoftOption(l10n.food, Icons.restaurant_menu_rounded, false),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSoftOption(String text, IconData icon, bool targetMode) {
    final isSelected = isFitnessMode == targetMode;
    final contentColor = isSelected ? activeColor : AppColors.textGray.withOpacity(0.7);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isFitnessMode = targetMode),
        behavior: HitTestBehavior.translucent,
        child: Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(icon, key: ValueKey(isSelected), color: contentColor, size: AppDimens.p20),
              ),
              const SizedBox(width: AppDimens.p8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTextStyles.label.copyWith(
                  color: contentColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  height: 1,
                ),
                child: Text(text),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroInputArea(AiCoachViewModel viewModel, AppLocalizations l10n) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.r24),
              boxShadow: [
                BoxShadow(
                    color: activeColor.withOpacity(0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 10)
                ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.r24),
          ),
          child: Column(
            children: [
              TextField(
                controller: _textController,
                maxLines: 5,
                minLines: 3,
                style: AppTextStyles.input,
                decoration: InputDecoration(
                  hintText: isFitnessMode ? l10n.inputHintFitness : l10n.inputHintFood,
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.textLight.withOpacity(0.8)),
                  border: InputBorder.none,
                  contentPadding: AppDimens.all24,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: AppDimens.p16,
                    right: AppDimens.p16,
                    bottom: AppDimens.p16
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(Icons.camera_alt_rounded, () => viewModel.pickImage(ImageSource.camera)),
                    const SizedBox(width: AppDimens.p12),
                    _buildActionButton(Icons.photo_library_rounded, () => viewModel.pickImage(ImageSource.gallery)),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.r12),
      child: Container(
        padding: const EdgeInsets.all(10), // İkon butonu için özel padding
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppDimens.r12)
        ),
        child: Icon(icon, color: AppColors.textGray, size: 22),
      ),
    );
  }

  Widget _buildImagePreview(AiCoachViewModel viewModel) {
    return Center(
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.r24),
          boxShadow: [ AppColors.shadowMedium ],
          image: DecorationImage(
              image: MemoryImage(viewModel.selectedImageBytes!),
              fit: BoxFit.cover
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 12, right: 12,
              child: GestureDetector(
                onTap: viewModel.clearImage,
                child: Container(
                  padding: AppDimens.all8,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: AppDimens.iconSmall),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}