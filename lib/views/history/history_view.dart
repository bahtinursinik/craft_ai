import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smart_resource_ai/core/constants/app_dimens.dart';
import 'package:smart_resource_ai/core/constants/app_theme.dart';
import 'package:smart_resource_ai/core/widgets/common_widgets.dart';
import 'package:smart_resource_ai/data/models/ai_model.dart';
import 'package:smart_resource_ai/viewmodels/user_view_model.dart';
import 'package:smart_resource_ai/views/results/result_view.dart';


class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context)!;
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.historyPlans,
          style: AppTextStyles.subHeader,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('history')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          // 2. VERİ YOK
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      Icons.history_toggle_off,
                      size: AppDimens.iconXLarge * 2,
                      color: AppColors.textLight.withOpacity(0.5)
                  ),
                  const SizedBox(height: AppDimens.p16),
                  Text(l10n.noHistoryYet, style: AppTextStyles.body),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: AppDimens.all24, // ✅ AppDimens
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimens.p16), // ✅
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data()! as Map<String, dynamic>;

              final isFood = data['type'] == 'food';
              final accentColor = isFood ? AppColors.foodAccent : AppColors.sportAccent;
              final icon = isFood ? Icons.restaurant_menu : Icons.fitness_center;
              final isCompleted = (data['isCompleted'] as bool?) ?? false;

              final title = (data['title'] as String?) ?? l10n.untitled;
              final calories = data['calories']?.toString() ?? '0';
              final duration = data['duration']?.toString() ?? '0';

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppDimens.p24),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(AppDimens.r20), // ✅
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: AppDimens.iconLarge),
                ),
                confirmDismiss: (direction) async {
                  return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.r20)),
                        title: Text(l10n.confirmDeleteTitle, style: AppTextStyles.subHeader),
                        content: Text(l10n.confirmDeleteMsg, style: AppTextStyles.body),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(l10n.cancel, style: AppTextStyles.label),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.r12)),
                            ),
                            child: Text(l10n.delete),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) async {
                  await userViewModel.deleteHistoryItem(doc.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.planDeleted),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        )
                    );
                  }
                },
                child: CleanCard(
                  padding: AppDimens.all16,
                  onTap: () {
                    try {
                      if (data['content'] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Bu kayıt bozuk."),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      final planMap = data['content'] as Map<String, dynamic>;
                      final planModel = AiModel.fromJson(planMap);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultView(
                            plan: planModel,
                            documentId: doc.id,
                            isCompleted: isCompleted,
                            isFitnessMode: !isFood,
                          ),
                        ),
                      );
                    } catch (e) {
                      debugPrint("Plan açma hatası: $e");
                    }
                  },
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: AppDimens.all12,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimens.r12),
                            ),
                            child: Icon(icon, color: accentColor, size: AppDimens.iconMedium),
                          ),
                          if (isCompleted)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: AppDimens.all4,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 10),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(width: AppDimens.p16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTextStyles.subHeader.copyWith(
                                fontSize: 16,
                                color: isCompleted ? AppColors.textGray : AppColors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppDimens.p4),
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department_outlined, size: 14, color: AppColors.textGray),
                                const SizedBox(width: 4),
                                Text(
                                  '$calories ${l10n.kcal}',
                                  style: AppTextStyles.body.copyWith(fontSize: 12),
                                ),
                                const SizedBox(width: AppDimens.p12),
                                const Icon(Icons.timer_outlined, size: 14, color: AppColors.textGray),
                                const SizedBox(width: 4),
                                Text(
                                  '$duration ${l10n.min}',
                                  style: AppTextStyles.body.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}