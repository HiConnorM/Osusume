import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/models/restaurant.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'ease_score_badge.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final bool horizontal;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/restaurant/${restaurant.id}'),
      child: horizontal ? _buildHorizontal(context) : _buildVertical(context),
    );
  }

  Widget _buildVertical(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: _buildImage(height: 156),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.nameEn,
                        style: AppTextStyles.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    EaseScoreBadge(score: restaurant.foreignerFactors.easeScore),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        restaurant.cuisine,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Text(' · ', style: TextStyle(color: AppColors.textTertiary)),
                    Text(
                      restaurant.priceString,
                      style: AppTextStyles.bodySmall,
                    ),
                    const Text(' · ', style: TextStyle(color: AppColors.textTertiary)),
                    Text(
                      restaurant.walkTimeString,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                    const SizedBox(width: 3),
                    Text(
                      restaurant.rating.toStringAsFixed(1),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '(${restaurant.reviewCount})',
                      style: AppTextStyles.caption,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: restaurant.isOpen
                            ? AppColors.tagGreen
                            : AppColors.tagGray,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        restaurant.isOpen ? 'Open' : 'Closed',
                        style: AppTextStyles.caption.copyWith(
                          color: restaurant.isOpen
                              ? AppColors.tagGreenText
                              : AppColors.tagGrayText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: _buildImage(width: 100, height: 100),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.nameEn,
                          style: AppTextStyles.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      EaseScoreBadge(score: restaurant.foreignerFactors.easeScore),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${restaurant.cuisine} · ${restaurant.priceString}',
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 13, color: AppColors.warning),
                      const SizedBox(width: 2),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.directions_walk_rounded,
                        size: 13,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 2),
                      Text(restaurant.walkTimeString, style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage({double? width, double? height}) {
    final photoUrl = restaurant.photos.isNotEmpty
        ? restaurant.photos.first.displayUrl
        : restaurant.imageUrl;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photoUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, _) => _shimmerPlaceholder(width: width, height: height),
        errorWidget: (_, _, _) => _fallbackPlaceholder(width: width, height: height),
      );
    }
    return _fallbackPlaceholder(width: width, height: height);
  }

  Widget _shimmerPlaceholder({double? width, double? height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(width: width, height: height, color: Colors.white),
    );
  }

  Widget _fallbackPlaceholder({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceAlt,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
          Center(
            child: Text(
              _cuisineEmoji(restaurant.cuisine),
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ],
      ),
    );
  }

  String _cuisineEmoji(String cuisine) {
    return switch (cuisine.toLowerCase()) {
      'ramen' => '🍜',
      'sushi' => '🍣',
      'yakitori' => '🍢',
      'tempura' => '🍤',
      'tonkatsu' => '🥩',
      'izakaya' => '🍶',
      'café / brunch' || 'café' || 'brunch' => '☕',
      'udon' || 'soba' => '🍝',
      _ => '🍽️',
    };
  }
}
