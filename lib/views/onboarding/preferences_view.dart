import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smart_resource_ai/core/constants/app_dimens.dart';
import 'package:smart_resource_ai/core/constants/app_theme.dart';
import 'package:smart_resource_ai/core/widgets/common_widgets.dart';
import 'package:smart_resource_ai/viewmodels/user_view_model.dart';
import 'package:smart_resource_ai/views/dashboard/dashboard_view.dart';

class PreferencesView extends StatefulWidget {

  const PreferencesView({super.key, this.isEditing = false});
  final bool isEditing;

  @override
  State<PreferencesView> createState() => _PreferencesViewState();
}

class _PreferencesViewState extends State<PreferencesView> {
  String? _selectedGoal;
  String? _selectedDiet;
  String? _selectedEquipment;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      Future.microtask(() {
        final userVM = Provider.of<UserViewModel>(context, listen: false);
        final data = userVM.userData;

        if (data != null) {
          setState(() {
            _selectedGoal = data['goal'] as String?;
            _selectedDiet = data['diet'] as String?;
            _selectedEquipment = data['equipment'] as String?;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: widget.isEditing,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: widget.isEditing
            ? Text(l10n.accountDetails, style: AppTextStyles.subHeader)
            : null,
        centerTitle: true,
        actions: [
          if (!widget.isEditing)
            TextButton(
              onPressed: () async {
                setState(() => _isLoading = true);
                final success = await userViewModel.markProfileAsComplete();
                setState(() => _isLoading = false);

                if (success && context.mounted) {
                  await Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardView()),
                          (route) => false);
                }
              },
              child: Text(
                l10n.skip,
                style: AppTextStyles.body.copyWith(color: AppColors.textGray),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppDimens.all24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isEditing) ...[
              Text(l10n.onboardingTitle, style: AppTextStyles.header.copyWith(fontSize: 28)),
              const SizedBox(height: AppDimens.p12),
              Text(l10n.onboardingSubtitle, style: AppTextStyles.body.copyWith(fontSize: 16)),
              const SizedBox(height: 40),
            ],

            _buildSectionTitle(l10n.goalLabel),
            _buildChipGroup(
              options: [l10n.goalLoseWeight, l10n.goalBuildMuscle, l10n.goalStayFit],
              selectedOption: _selectedGoal,
              onSelect: (val) => setState(() => _selectedGoal = val),
              activeColor: AppColors.primary,
            ),
            const SizedBox(height: AppDimens.p32),

            _buildSectionTitle(l10n.dietLabel),
            _buildChipGroup(
              options: [l10n.dietNone, l10n.dietVegetarian, l10n.dietVegan, l10n.dietPaleo],
              selectedOption: _selectedDiet,
              onSelect: (val) => setState(() => _selectedDiet = val),
              activeColor: AppColors.foodAccent,
            ),
            const SizedBox(height: AppDimens.p32),

            _buildSectionTitle(l10n.equipmentLabel),
            _buildChipGroup(
              options: [l10n.equipBodyweight, l10n.equipDumbbells, l10n.equipGym],
              selectedOption: _selectedEquipment,
              onSelect: (val) => setState(() => _selectedEquipment = val),
              activeColor: AppColors.sportAccent,
            ),

            const SizedBox(height: 50),

            CustomButton(
              text: widget.isEditing ? l10n.update : l10n.saveAndContinue,
              isLoading: _isLoading || userViewModel.isLoading,
              onTap: () async {
                if (_selectedGoal == null || _selectedDiet == null || _selectedEquipment == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Lütfen tüm seçenekleri belirleyiniz."),
                          backgroundColor: AppColors.error
                      )
                  );
                  return;
                }

                setState(() => _isLoading = true);

                final success = await userViewModel.saveOnboardingData(
                  goal: _selectedGoal!,
                  diet: _selectedDiet!,
                  equipment: _selectedEquipment!,
                );

                setState(() => _isLoading = false);

                if (success && context.mounted) {
                  if (widget.isEditing) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(l10n.profileUpdated),
                            backgroundColor: AppColors.success
                        )
                    );
                  } else {
                    await Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardView()),
                            (route) => false
                    );
                  }
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.errorOccurred), backgroundColor: AppColors.error)
                  );
                }
              },
            ),
            const SizedBox(height: AppDimens.p20),
          ],
        ),
      ),
    );
  }


  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.p16),
      child: Text(title, style: AppTextStyles.subHeader.copyWith(fontSize: 18)),
    );
  }

  Widget _buildChipGroup({
    required List<String> options,
    required String? selectedOption,
    required Function(String) onSelect,
    required Color activeColor,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 12,
      children: options.map((option) {
        final isSelected = selectedOption == option;
        return ChoiceChip(
          label: Text(option),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              onSelect(option);
            }
          },
          selectedColor: activeColor,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.r20),
              side: BorderSide(
                  color: isSelected ? activeColor : Colors.grey.shade300,
                  width: 1.5
              )
          ),
          elevation: isSelected ? 2 : 0,
          pressElevation: 2,
        );
      }).toList(),
    );
  }
}