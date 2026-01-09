import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smart_resource_ai/core/constants/app_dimens.dart';

import 'package:smart_resource_ai/core/constants/app_theme.dart';
import 'package:smart_resource_ai/core/widgets/common_widgets.dart';

class HistorySkeletonList extends StatelessWidget {
  const HistorySkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.separated(
        padding: AppDimens.all24,
        itemCount: 6,
        separatorBuilder: (_, _) => AppDimens.gapH16,
        itemBuilder: (_, _) => const _FakeHistoryCard(),
      ),
    );
  }
}

class _FakeHistoryCard extends StatelessWidget {
  const _FakeHistoryCard();

  @override
  Widget build(BuildContext context) {
    return CleanCard(
      padding: AppDimens.all16,
      child: Row(
        children: [
          Container(
            padding: AppDimens.all12,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.r12),
            ),
            child: const Icon(
                Icons.fitness_center,
                color: AppColors.primary,
                size: AppDimens.iconMedium
            ),
          ),

          AppDimens.gapW16,

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sample Workout Plan Title Long',
                  style: AppTextStyles.subHeader.copyWith(fontSize: 16),
                  maxLines: 1,
                ),

                AppDimens.gapH4,

                Row(
                  children: [
                    const Icon(Icons.local_fire_department_outlined, size: AppDimens.iconSmall),
                    AppDimens.gapW4,
                    Text('500 kcal', style: AppTextStyles.body.copyWith(fontSize: 12)),

                    AppDimens.gapW12,

                    const Icon(Icons.timer_outlined, size: AppDimens.iconSmall),
                    AppDimens.gapW4,

                    Text('45 min', style: AppTextStyles.body.copyWith(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: AppDimens.iconSmall),
        ],
      ),
    );
  }
}