import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/restaurant.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/ease_score_badge.dart';
import '../../../shared/widgets/osusume_tag.dart';

/// Draggable bottom sheet shown when a map marker is tapped.
/// Shows full restaurant data with actions.
class RestaurantMapSheet extends StatelessWidget {
  final Restaurant restaurant;
  final double distanceKm;

  const RestaurantMapSheet({
    super.key,
    required this.restaurant,
    required this.distanceKm,
  });

  String get _walkTime {
    final mins = (distanceKm * 12).round().clamp(1, 999);
    return '$mins min walk';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20, 4, 20, MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 12),
                  _buildMetaRow(),
                  const SizedBox(height: 14),
                  _buildEaseRow(),
                  const SizedBox(height: 14),
                  if (restaurant.tags.isNotEmpty) ...[
                    _buildTags(),
                    const SizedBox(height: 14),
                  ],
                  if (restaurant.recommendationReason != null) ...[
                    _buildReason(),
                    const SizedBox(height: 16),
                  ],
                  _buildFactsGrid(),
                  const SizedBox(height: 20),
                  _buildActions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cuisine emoji avatar
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(_emoji, style: const TextStyle(fontSize: 26)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(restaurant.nameEn, style: AppTextStyles.headingSmall),
              const SizedBox(height: 2),
              Text(
                restaurant.nameJa,
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
        // Open/closed badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: restaurant.isOpen ? AppColors.tagGreen : AppColors.tagGray,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: restaurant.isOpen
                      ? AppColors.tagGreenText
                      : AppColors.tagGrayText,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                restaurant.isOpen ? 'Open' : 'Closed',
                style: AppTextStyles.caption.copyWith(
                  color: restaurant.isOpen
                      ? AppColors.tagGreenText
                      : AppColors.tagGrayText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow() {
    return Row(
      children: [
        Icon(Icons.place_outlined, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(restaurant.neighborhood, style: AppTextStyles.bodySmall),
        _dot,
        Text(restaurant.cuisine, style: AppTextStyles.bodySmall),
        _dot,
        Text(restaurant.priceString, style: AppTextStyles.bodySmall),
        const Spacer(),
        Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
        const SizedBox(width: 3),
        Text(
          restaurant.rating.toStringAsFixed(1),
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(width: 2),
        Text('(${restaurant.reviewCount})', style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildEaseRow() {
    return Row(
      children: [
        EaseScoreBadge(score: restaurant.foreignerFactors.easeScore, large: true),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Icon(Icons.directions_walk_rounded,
                  size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(_walkTime, style: AppTextStyles.bodySmall),
              _dot,
              Text(
                distanceKm < 1
                    ? '${(distanceKm * 1000).round()}m away'
                    : '${distanceKm.toStringAsFixed(1)}km away',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: restaurant.tags
          .map((t) => OsusumeTag(label: t, variant: TagVariant.orange))
          .toList(),
    );
  }

  Widget _buildReason() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✨', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              restaurant.recommendationReason!,
              style: AppTextStyles.bodySmall.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactsGrid() {
    final ff = restaurant.foreignerFactors;
    final facts = <_Fact>[
      _Fact(Icons.translate_rounded, 'English menu',
          ff.englishMenu == true, ff.englishMenu),
      _Fact(Icons.credit_card_rounded, 'Card payment',
          ff.cardPayment == true, ff.cardPayment),
      _Fact(Icons.directions_walk_rounded, 'Walk-ins OK',
          ff.walkInFriendly == true, ff.walkInFriendly),
      _Fact(Icons.person_rounded, 'Solo-friendly',
          ff.soloFriendly == true, ff.soloFriendly),
      _Fact(Icons.eco_rounded, 'Vegan options',
          ff.veganOptions == true, ff.veganOptions),
      _Fact(Icons.child_friendly_rounded, 'Kid-friendly',
          ff.kidFriendly == true, ff.kidFriendly),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: facts.length,
      itemBuilder: (_, i) => _FactChip(fact: facts[i]),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.info_outline_rounded,
            label: 'Details',
            onTap: () {
              Navigator.of(context).pop();
              context.push('/restaurant/${restaurant.id}');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.translate_rounded,
            label: 'Menu',
            onTap: () {
              Navigator.of(context).pop();
              context.go('/translate');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.calendar_month_rounded,
            label: 'Book',
            onTap: () {
              Navigator.of(context).pop();
              context.push('/reserve/${restaurant.id}');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.bookmark_outline_rounded,
            label: 'Save',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to your list')),
              );
            },
          ),
        ),
      ],
    );
  }

  String get _emoji => switch (restaurant.cuisine.toLowerCase()) {
        'ramen' => '🍜',
        'sushi' => '🍣',
        'yakitori' => '🍢',
        'tempura' => '🍤',
        'gyukatsu' => '🥩',
        'innovative' => '⭐',
        'café / brunch' || 'café' || 'brunch' => '☕',
        _ => '🍽️',
      };

  Widget get _dot => const Text(
        ' · ',
        style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
      );
}

class _Fact {
  final IconData icon;
  final String label;
  final bool value;
  final bool? raw;

  const _Fact(this.icon, this.label, this.value, this.raw);
}

class _FactChip extends StatelessWidget {
  final _Fact fact;

  const _FactChip({required this.fact});

  @override
  Widget build(BuildContext context) {
    final isUnknown = fact.raw == null;
    final color = isUnknown
        ? AppColors.textTertiary
        : fact.value
            ? AppColors.easeHigh
            : AppColors.easeLow;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUnknown
                ? Icons.help_outline_rounded
                : fact.value
                    ? Icons.check_rounded
                    : Icons.close_rounded,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              fact.label,
              style: AppTextStyles.caption.copyWith(
                color: isUnknown ? AppColors.textTertiary : AppColors.textPrimary,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
