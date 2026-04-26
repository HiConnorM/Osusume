import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum TagVariant { green, orange, blue, gray }

class OsusumeTag extends StatelessWidget {
  final String label;
  final TagVariant variant;
  final IconData? icon;

  const OsusumeTag({
    super.key,
    required this.label,
    this.variant = TagVariant.gray,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      TagVariant.green => (AppColors.tagGreen, AppColors.tagGreenText),
      TagVariant.orange => (AppColors.tagOrange, AppColors.tagOrangeText),
      TagVariant.blue => (AppColors.tagBlue, AppColors.tagBlueText),
      TagVariant.gray => (AppColors.tagGray, AppColors.tagGrayText),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: fg)),
        ],
      ),
    );
  }
}
