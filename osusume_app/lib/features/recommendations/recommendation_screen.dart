import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/restaurant.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/ease_score_badge.dart';
import '../../shared/widgets/osusume_tag.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  List<Restaurant> get _restaurants => MockRestaurants.all;

  Restaurant get _current => _restaurants[_currentIndex % _restaurants.length];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _animController.forward();
  }

  void _showAnother() {
    HapticFeedback.lightImpact();
    _animController.reset();
    setState(() => _currentIndex++);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Recommended for you'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Filters'),
          ),
        ],
      ),
      body: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: _buildCard(context, _current),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Restaurant r) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant hero
            _buildHero(context, r),
            const SizedBox(height: 20),

            // "Why this place" reason
            if (r.recommendationReason != null) ...[
              _buildReasonBox(r.recommendationReason!),
              const SizedBox(height: 20),
            ],

            // Quick facts grid
            _buildQuickFacts(r),
            const SizedBox(height: 20),

            // Foreigner ease
            EaseScoreBadge(score: r.foreignerFactors.easeScore, large: true),
            const SizedBox(height: 28),

            // Action buttons
            _buildActions(context, r),
            const SizedBox(height: 16),
            _buildSecondaryActions(context, r),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, Restaurant r) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            AppColors.primary.withValues(alpha: 0.06),
          ],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _cuisineEmoji(r.cuisine),
                  style: const TextStyle(fontSize: 72),
                ),
              ],
            ),
          ),
          // Overlay bottom info
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ...r.tags.take(2).map((t) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: OsusumeTag(
                              label: t,
                              variant: TagVariant.orange,
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    r.nameEn,
                    style: AppTextStyles.displaySmall.copyWith(color: Colors.white),
                  ),
                  Text(
                    r.nameJa,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Open badge
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: r.isOpen ? AppColors.easeHigh : AppColors.easeLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    r.isOpen ? 'Open now' : 'Closed',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonBox(String reason) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✨', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why we picked this',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(reason, style: AppTextStyles.bodySmall.copyWith(height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFacts(Restaurant r) {
    final ff = r.foreignerFactors;
    final facts = <_Fact>[
      _Fact(
        icon: Icons.directions_walk_rounded,
        label: r.walkTimeString,
        sub: r.neighborhood,
      ),
      _Fact(
        icon: Icons.attach_money_rounded,
        label: r.priceString,
        sub: 'per person',
      ),
      _Fact(
        icon: Icons.translate_rounded,
        label: ff.englishMenu == true ? 'English menu' : 'Japanese menu',
        sub: ff.englishMenu == true ? 'Available' : 'Photo menu likely',
        good: ff.englishMenu,
      ),
      _Fact(
        icon: Icons.credit_card_rounded,
        label: ff.cardPayment == true ? 'Card OK' : 'Cash only',
        sub: ff.suicaPayment == true ? 'Suica too' : null,
        good: ff.cardPayment,
      ),
      _Fact(
        icon: Icons.event_rounded,
        label: ff.reservationRequired == true
            ? 'Reservation required'
            : 'Walk-ins welcome',
        sub: ff.reservationRequired == true ? 'Book ahead' : null,
        good: ff.reservationRequired != true,
      ),
      _Fact(
        icon: Icons.person_rounded,
        label: ff.soloFriendly == true ? 'Solo-friendly' : 'Better with company',
        sub: null,
        good: ff.soloFriendly,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: facts.length,
      itemBuilder: (context, i) => _FactTile(fact: facts[i]),
    );
  }

  Widget _buildActions(BuildContext context, Restaurant r) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/restaurant/${r.id}'),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Looks good'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: _showAnother,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryActions(BuildContext context, Restaurant r) {
    return Row(
      children: [
        _SecondaryAction(
          icon: Icons.bookmark_outline_rounded,
          label: 'Save',
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saved to your list')),
            );
          },
        ),
        _SecondaryAction(
          icon: Icons.directions_rounded,
          label: 'Directions',
          onTap: () {},
        ),
        _SecondaryAction(
          icon: Icons.translate_rounded,
          label: 'Menu help',
          onTap: () => context.push('/translate'),
        ),
        _SecondaryAction(
          icon: Icons.calendar_month_rounded,
          label: 'Book',
          onTap: () => context.push('/reserve/${r.id}'),
        ),
      ],
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
      _ => '🍽️',
    };
  }
}

class _Fact {
  final IconData icon;
  final String label;
  final String? sub;
  final bool? good;

  const _Fact({
    required this.icon,
    required this.label,
    this.sub,
    this.good,
  });
}

class _FactTile extends StatelessWidget {
  final _Fact fact;

  const _FactTile({required this.fact});

  @override
  Widget build(BuildContext context) {
    final color = fact.good == null
        ? AppColors.textSecondary
        : fact.good!
            ? AppColors.easeHigh
            : AppColors.easeLow;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(fact.icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fact.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (fact.sub != null)
                  Text(fact.sub!, style: AppTextStyles.caption, maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 5),
              Text(label, style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}
