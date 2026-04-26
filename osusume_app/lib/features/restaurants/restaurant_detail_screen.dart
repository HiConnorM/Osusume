import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/restaurant.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/ease_score_badge.dart';
import '../../shared/widgets/osusume_tag.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  bool _saved = false;
  int _selectedTab = 0;

  Restaurant get r => widget.restaurant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildContent(context)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: Icon(
                _saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                size: 20,
                color: _saved ? AppColors.primary : AppColors.textPrimary,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _saved = !_saved);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_saved ? 'Saved to your list' : 'Removed from saved'),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.share_outlined, size: 20),
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
              ),
            ),
            Center(
              child: Text(
                _cuisineEmoji(r.cuisine),
                style: const TextStyle(fontSize: 80),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.background, Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildRatingRow(),
          const SizedBox(height: 16),
          _buildTagsRow(),
          const SizedBox(height: 24),
          EaseScoreBadge(score: r.foreignerFactors.easeScore, large: true),
          const SizedBox(height: 28),
          _buildSectionTabs(),
          const SizedBox(height: 20),
          if (_selectedTab == 0) _buildOverviewTab(),
          if (_selectedTab == 1) _buildForeignerTab(),
          if (_selectedTab == 2) _buildEtiquetteTab(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.nameEn, style: AppTextStyles.displaySmall),
                  const SizedBox(height: 2),
                  Text(
                    r.nameJa,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: r.isOpen ? AppColors.tagGreen : AppColors.tagGray,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: r.isOpen ? AppColors.tagGreenText : AppColors.tagGrayText,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    r.isOpen ? 'Open' : 'Closed',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: r.isOpen ? AppColors.tagGreenText : AppColors.tagGrayText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.place_outlined, size: 14, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              '${r.neighborhood} · ${r.walkTimeString}',
              style: AppTextStyles.bodySmall,
            ),
            const Text(' · ', style: TextStyle(color: AppColors.textTertiary)),
            Text(r.cuisine, style: AppTextStyles.bodySmall),
            const Text(' · ', style: TextStyle(color: AppColors.textTertiary)),
            Text(r.priceString, style: AppTextStyles.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        ...List.generate(5, (i) {
          final filled = i < r.rating.floor();
          final half = !filled && i < r.rating;
          return Icon(
            half ? Icons.star_half_rounded : Icons.star_rounded,
            size: 20,
            color: filled || half ? AppColors.warning : AppColors.divider,
          );
        }),
        const SizedBox(width: 8),
        Text(
          r.rating.toStringAsFixed(1),
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(width: 4),
        Text(
          '(${r.reviewCount} reviews)',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTagsRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: r.tags
          .map((t) => OsusumeTag(label: t, variant: TagVariant.orange))
          .toList(),
    );
  }

  Widget _buildSectionTabs() {
    final tabs = ['Overview', 'Foreigner Tips', 'Etiquette'];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: tabs.asMap().entries.map((e) {
          final selected = _selectedTab == e.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 4,
                          )
                        ]
                      : null,
                ),
                child: Text(
                  e.value,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: selected ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (r.description != null) ...[
          Text('About', style: AppTextStyles.headingSmall),
          const SizedBox(height: 8),
          Text(r.description!, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 20),
        ],
        Text('Details', style: AppTextStyles.headingSmall),
        const SizedBox(height: 12),
        _DetailRow(
          icon: Icons.location_on_outlined,
          label: 'Address',
          value: r.address,
        ),
        _DetailRow(
          icon: Icons.access_time_rounded,
          label: 'Hours',
          value: 'Mon–Sun  11:00–23:00',
          valueColor: r.isOpen ? AppColors.easeHigh : AppColors.easeLow,
        ),
        _DetailRow(
          icon: Icons.restaurant_menu_rounded,
          label: 'Cuisine',
          value: r.cuisine,
        ),
        _DetailRow(
          icon: Icons.payments_outlined,
          label: 'Price range',
          value: '${r.priceString} per person',
        ),
      ],
    );
  }

  Widget _buildForeignerTab() {
    final ff = r.foreignerFactors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('At a glance', style: AppTextStyles.headingSmall),
        const SizedBox(height: 12),
        _ForeignerRow(
          label: 'English menu',
          value: ff.englishMenu,
          trueText: 'Available',
          falseText: 'Japanese only',
        ),
        _ForeignerRow(
          label: 'English-speaking staff',
          value: ff.englishStaff,
          trueText: 'Likely',
          falseText: 'Unlikely',
        ),
        _ForeignerRow(
          label: 'Card payment',
          value: ff.cardPayment,
          trueText: 'Accepted',
          falseText: 'Cash only',
        ),
        _ForeignerRow(
          label: 'IC card (Suica / Pasmo)',
          value: ff.suicaPayment,
          trueText: 'Accepted',
          falseText: 'Not accepted',
        ),
        _ForeignerRow(
          label: 'Walk-ins welcome',
          value: ff.walkInFriendly,
          trueText: 'Yes',
          falseText: 'Reservation needed',
        ),
        _ForeignerRow(
          label: 'Solo-friendly',
          value: ff.soloFriendly,
          trueText: 'Great for solo',
          falseText: 'Better with company',
        ),
        _ForeignerRow(
          label: 'Allergy-friendly',
          value: ff.allergyFriendly,
          trueText: 'Can accommodate',
          falseText: 'Limited flexibility',
        ),
        _ForeignerRow(
          label: 'Vegetarian options',
          value: ff.vegetarianOptions,
          trueText: 'Available',
          falseText: 'Very limited',
        ),
        _ForeignerRow(
          label: 'Vegan options',
          value: ff.veganOptions,
          trueText: 'Available',
          falseText: 'Not available',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.tagGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Foreigner ease scores are estimated based on community reports. Always verify allergy and dietary information directly with the restaurant.',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEtiquetteTab() {
    final tips = [
      ('🎌', 'Say "Irasshaimase!"', 'Staff will greet you warmly when you enter. A nod is a fine response.'),
      ('🍜', 'Slurping is fine', 'Slurping noodles is completely normal in Japan — it\'s a compliment to the chef.'),
      ('💴', 'Pay at the register', 'In most restaurants, you pay at the front, not at the table.'),
      ('🙏', 'Say "Itadakimasu"', 'A polite phrase said before eating, similar to "bon appétit."'),
      ('🚬', 'Check smoking rules', 'Some restaurants have smoking sections. Look for 禁煙 (no smoking) signs.'),
      ('📲', 'Calling for the check', 'Say "Okaikei onegaishimasu" or press the call button to get the bill.'),
    ];

    return Column(
      children: tips.map((t) {
        final (emoji, title, body) = t;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.labelMedium),
                    const SizedBox(height: 3),
                    Text(body, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.push('/translate'),
              icon: const Icon(Icons.translate_rounded, size: 18),
              label: const Text('Menu help'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push('/reserve/${r.id}'),
              icon: const Icon(Icons.calendar_month_rounded, size: 18),
              label: const Text('Book table'),
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
      _ => '🍽️',
    };
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.bodySmall),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ForeignerRow extends StatelessWidget {
  final String label;
  final bool? value;
  final String trueText;
  final String falseText;

  const _ForeignerRow({
    required this.label,
    required this.value,
    required this.trueText,
    required this.falseText,
  });

  @override
  Widget build(BuildContext context) {
    final isTrue = value == true;
    final isUnknown = value == null;
    final color = isUnknown
        ? AppColors.textTertiary
        : isTrue
            ? AppColors.easeHigh
            : AppColors.easeLow;
    final text = isUnknown ? 'Unknown' : isTrue ? trueText : falseText;
    final icon = isUnknown
        ? Icons.help_outline_rounded
        : isTrue
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
