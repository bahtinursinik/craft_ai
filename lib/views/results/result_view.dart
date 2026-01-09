import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_resource_ai/core/constants/app_dimens.dart';
import 'package:smart_resource_ai/core/constants/app_theme.dart';
import 'package:smart_resource_ai/core/widgets/common_widgets.dart';
import 'package:smart_resource_ai/data/models/ai_model.dart';
import 'package:smart_resource_ai/data/services/notification_service.dart';
import 'package:smart_resource_ai/viewmodels/ai_coach_view_model.dart';
import 'package:smart_resource_ai/viewmodels/user_view_model.dart';

class ResultView extends StatefulWidget {

  const ResultView({
    super.key,
    this.plan,
    this.documentId,
    this.isCompleted = false,
    this.isFitnessMode = true,
  });
  final AiModel? plan;
  final String? documentId;
  final bool isCompleted;
  final bool isFitnessMode;

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  bool isSaved = false;
  bool _isCompleting = false;

  void _sharePlan(AiModel plan, AppLocalizations l10n) {
    final sb = StringBuffer()

    ..writeln('🚀 ${plan.title}')
    ..writeln('-------------------------')

    ..writeln('📝 ${plan.description}')
    ..writeln('🔥 ${plan.calories} kcal  |  ⏱️ ${plan.duration} ${l10n.min}') // dk -> l10n.min
    ..writeln('-------------------------\n')

    ..writeln('👇 ${l10n.steps}:');
    for (var i = 0; i < plan.steps.length; i++) {
      sb.writeln('${i + 1}. ${plan.steps[i]}');
    }

    sb.writeln('\n✨ Created with Smart Resource AI');

    Share.share(sb.toString(), subject: plan.title);
  }

  @override
  void initState() {
    super.initState();
    if (widget.documentId != null) {
      isSaved = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final aiViewModel = Provider.of<AiCoachViewModel>(context);
    AiModel? displayPlan;

    if (widget.documentId != null) {
      displayPlan = widget.plan;
    } else {
      displayPlan = aiViewModel.currentPlan;
    }

    final activeColor = widget.documentId != null
        ? (widget.isFitnessMode ? AppColors.sportAccent : AppColors.foodAccent)
        : AppColors.primary;

    if (displayPlan == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textDark),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)
          ),
        ),
        body: Center(child: Text(l10n.dataNotFound, style: AppTextStyles.body)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.yourPlan, style: AppTextStyles.subHeader),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: AppDimens.all8,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimens.p16),
            child: IconButton(
              icon: Container(
                padding: AppDimens.all8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [AppColors.shadowLow],
                ),
                child: Icon(Icons.ios_share, color: activeColor, size: 20),
              ),
              onPressed: () => _sharePlan(displayPlan!, l10n),
            ),
          ),
        ],
      ),

      floatingActionButton: widget.documentId == null ? FloatingActionButton.extended(
        onPressed: isSaved
            ? null
            : () async {
          final success = await aiViewModel.saveCurrentPlanToHistory(
              isFitness: widget.isFitnessMode
          );

          if (success) {
            setState(() => isSaved = true);
            await NotificationService().showNotification(
              id: 1,
              title: l10n.planSavedMessage,
              body: '${displayPlan?.title} ${l10n.historyPlans}',
              channelName: l10n.notificationChannelGeneral,
              channelDesc: l10n.notificationChannelGeneralDesc,
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.planSavedMessage),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        backgroundColor: isSaved ? AppColors.textLight : activeColor,
        elevation: 4,
        icon: Icon(isSaved ? Icons.check : Icons.bookmark_add, color: Colors.white),
        label: Text(
          isSaved ? l10n.saved : l10n.save,
          style: AppTextStyles.buttonText,
        ),
      ) : null,

      body: SingleChildScrollView(
        padding: AppDimens.all24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              padding: AppDimens.all24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [activeColor, activeColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppDimens.r24),
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: AppDimens.r20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBadge(displayPlan.difficulty, Colors.white.withOpacity(0.2)),
                      const Icon(Icons.auto_awesome, color: Colors.white70),
                    ],
                  ),
                  const SizedBox(height: AppDimens.p16),
                  Text(
                    displayPlan.title,
                    style: AppTextStyles.header.copyWith(color: Colors.white, height: 1.2),
                  ),
                  const SizedBox(height: AppDimens.p8),
                  Text(
                    displayPlan.description,
                    style: AppTextStyles.body.copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(height: AppDimens.p24),
                  Row(
                    children: [
                      _buildStat(Icons.timer_outlined, '${displayPlan.duration} ${l10n.min}'),
                      const SizedBox(width: AppDimens.p24),
                      _buildStat(Icons.local_fire_department_outlined, '${displayPlan.calories} ${l10n.kcal}'),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: AppDimens.p32),

            Text(l10n.steps, style: AppTextStyles.subHeader),
            const SizedBox(height: AppDimens.p16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayPlan.steps.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppDimens.p12),
              itemBuilder: (context, index) {
                return _buildStepCard(index + 1, displayPlan!.steps[index], activeColor);
              },
            ),

            const SizedBox(height: 40),

            if (widget.documentId != null) ...[
              if (!widget.isCompleted)
                CustomButton(
                  text: l10n.markAsCompleted,
                  color: AppColors.success,
                  isLoading: _isCompleting,
                  onTap: () async {
                    setState(() => _isCompleting = true);

                    final userVM = Provider.of<UserViewModel>(context, listen: false);
                    final success = await userVM.markHistoryItemAsCompleted(widget.documentId!);

                    setState(() => _isCompleting = false);

                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.planCompletedMsg),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          )
                      );
                    }
                  },
                ),

              if (widget.isCompleted)
                Container(
                  padding: AppDimens.all16,
                  decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimens.r16),
                      border: Border.all(color: AppColors.success.withOpacity(0.5))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: AppDimens.p12),
                      Text(
                        l10n.thisPlanIsCompleted,
                        style: AppTextStyles.subHeader.copyWith(color: AppColors.success, fontSize: 16),
                      ),
                    ],
                  ),
                ),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }


  Widget _buildBadge(String text, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.p12, vertical: 6),
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimens.r20),
          border: Border.all(color: Colors.white.withOpacity(0.3))
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: AppDimens.p8),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildStepCard(int index, String text, Color color) {
    return CleanCard(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.p16, horizontal: AppDimens.p20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.p16),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
