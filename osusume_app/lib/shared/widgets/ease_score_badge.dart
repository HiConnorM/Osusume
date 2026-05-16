import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class EaseScoreBadge extends StatelessWidget {
  final int score;
  final bool large;

  const EaseScoreBadge({super.key, required this.score, this.large = false});

  Color get _color {
    if (score >= 70) return AppColors.easeHigh;
    if (score >= 40) return AppColors.easeMid;
    return AppColors.easeLow;
  }

  String get _label {
    if (score >= 80) return 'Very Easy';
    if (score >= 60) return 'Easy';
    if (score >= 40) return 'Moderate';
    if (score >= 20) return 'Hard';
    return 'Difficult';
  }

  @override
  Widget build(BuildContext context) {
    if (large) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _color.withValues(alpha:0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _color.withValues(alpha:0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Foreigner Ease',
                  style: AppTextStyles.caption.copyWith(color: _color.withValues(alpha:0.8)),
                ),
                Text(
                  '$score / 100 · $_label',
                  style: AppTextStyles.labelMedium.copyWith(color: _color),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha:0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            '$score',
            style: AppTextStyles.labelSmall.copyWith(color: _color),
          ),
        ],
      ),
    );
  }
}
