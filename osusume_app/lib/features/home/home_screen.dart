import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/restaurant_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/restaurant_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  bool _showStickyHeader = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 100;
      if (show != _showStickyHeader) setState(() => _showStickyHeader = show);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildQuickActions(context)),
          SliverToBoxAdapter(child: _buildSectionHeader('Near you now', onSeeAll: () {})),
          SliverToBoxAdapter(child: _buildNearbyCarousel()),
          SliverToBoxAdapter(child: _buildSectionHeader('Popular in Tokyo')),
          _buildPopularList(),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      floating: true,
      snap: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      expandedHeight: 130,
      collapsedHeight: 70,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/app_icon.png', width: 28, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Osusume!',
                      style: AppTextStyles.headingLarge.copyWith(color: AppColors.primary),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded),
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Good evening! 🌃',
                  style: AppTextStyles.displaySmall,
                ),
              ],
            ),
          ),
        ),
        collapseMode: CollapseMode.pin,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(Icons.search_rounded, size: 20, color: AppColors.textTertiary),
                  const SizedBox(width: 10),
                  Text(
                    'Search restaurants...',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Filter',
                          style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.auto_awesome_rounded,
        label: 'Recommend',
        sublabel: 'something',
        color: AppColors.primary,
        onTap: () => context.push('/recommend'),
      ),
      _QuickAction(
        icon: Icons.translate_rounded,
        label: 'Translate',
        sublabel: 'a menu',
        color: const Color(0xFF6366F1),
        onTap: () => context.go('/translate'),
      ),
      _QuickAction(
        icon: Icons.calendar_month_rounded,
        label: 'Book',
        sublabel: 'a table',
        color: const Color(0xFF059669),
        onTap: () => context.push('/reserve/1'),
      ),
      _QuickAction(
        icon: Icons.map_rounded,
        label: 'Explore',
        sublabel: 'nearby',
        color: const Color(0xFFD97706),
        onTap: () {},
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What do you need?', style: AppTextStyles.headingSmall),
          const SizedBox(height: 14),
          Row(
            children: actions.map((a) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: a == actions.last ? 0 : 10,
                  ),
                  child: _QuickActionButton(action: a),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Feature cards row
          Row(
            children: [
              Expanded(child: _buildFeatureCard(
                '🍜',
                'Ramen near me',
                'Open now',
                AppColors.primary,
                () => context.push('/recommend'),
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildFeatureCard(
                '🌙',
                'Late night spots',
                '12+ venues',
                const Color(0xFF6366F1),
                () {},
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String emoji,
    String title,
    String sub,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelMedium),
                  Text(sub, style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.headingSmall),
          const Spacer(),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('See all'),
            ),
        ],
      ),
    );
  }

  Widget _buildNearbyCarousel() {
    final nearby = ref.watch(nearbyRestaurantsProvider);
    return nearby.when(
      loading: () => const SizedBox(
        height: 270,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox(
        height: 270,
        child: Center(child: Text('Could not load restaurants')),
      ),
      data: (restaurants) {
        if (restaurants.isEmpty) {
          return const SizedBox(
            height: 270,
            child: Center(child: Text('No restaurants nearby')),
          );
        }
        return SizedBox(
          height: 270,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: restaurants.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: SizedBox(
                  width: 220,
                  child: RestaurantCard(restaurant: restaurants[i]),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPopularList() {
    final nearby = ref.watch(nearbyRestaurantsProvider);
    return nearby.when(
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
      data: (restaurants) {
        final popular = (restaurants.toList()
              ..sort((a, b) => b.rating.compareTo(a.rating)))
            .take(5)
            .toList();
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RestaurantCard(restaurant: popular[i], horizontal: true),
              ),
              childCount: popular.length,
            ),
          ),
        );
      },
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: action.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, color: action.color, size: 26),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary),
            ),
            Text(
              action.sublabel,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
