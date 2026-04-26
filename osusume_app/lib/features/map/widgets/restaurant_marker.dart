import 'package:flutter/material.dart';
import '../../../core/models/restaurant.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class RestaurantMarker extends StatelessWidget {
  final Restaurant restaurant;
  final bool isSelected;
  final VoidCallback onTap;

  const RestaurantMarker({
    super.key,
    required this.restaurant,
    required this.isSelected,
    required this.onTap,
  });

  Color get _markerColor {
    if (!restaurant.isOpen) return AppColors.textTertiary;
    final score = restaurant.foreignerFactors.easeScore;
    if (score >= 70) return AppColors.primary;
    if (score >= 40) return AppColors.warning;
    return AppColors.easeLow;
  }

  String get _emoji => switch (restaurant.cuisine.toLowerCase()) {
        'ramen' => '🍜',
        'sushi' => '🍣',
        'yakitori' => '🍢',
        'tempura' => '🍤',
        'gyukatsu' => '🥩',
        'izakaya' => '🍶',
        'café / brunch' || 'café' || 'brunch' => '☕',
        'innovative' => '⭐',
        _ => '🍽️',
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBubble(),
            _buildStem(),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: isSelected ? 10 : 8,
        vertical: isSelected ? 6 : 5,
      ),
      decoration: BoxDecoration(
        color: isSelected ? _markerColor : Colors.white,
        borderRadius: BorderRadius.circular(isSelected ? 14 : 12),
        border: Border.all(
          color: _markerColor,
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _markerColor.withValues(alpha: isSelected ? 0.35 : 0.18),
            blurRadius: isSelected ? 12 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isSelected
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 90),
                  child: Text(
                    restaurant.nameEn,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : Text(_emoji, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildStem() {
    return CustomPaint(
      size: const Size(10, 6),
      painter: _StemPainter(
        color: isSelected ? _markerColor : Colors.white,
        borderColor: _markerColor,
      ),
    );
  }
}

class _StemPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  const _StemPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(borderPath, borderPaint);

    final fillPath = Path()
      ..moveTo(1.5, 0)
      ..lineTo(size.width - 1.5, 0)
      ..lineTo(size.width / 2, size.height - 1.5)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(_StemPainter old) =>
      color != old.color || borderColor != old.borderColor;
}
