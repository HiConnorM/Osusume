import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Preference state
  String? _tripType; // first_time, returning, expat
  final Set<String> _dietaryNeeds = {};
  String? _budget; // low, mid, high, any
  String? _comfort; // easy, moderate, adventurous

  static const _pages = [
    _OnboardingPage(
      emoji: '👋',
      title: 'Welcome to\nOsusume!',
      subtitle:
          'Your personal Japan dining guide. Find the right restaurant, understand the menu, and book with confidence.',
      isIntro: true,
    ),
    _OnboardingPage(
      emoji: '🗾',
      title: 'What brings you\nto Japan?',
      subtitle: 'We\'ll tailor recommendations to where you are in your Japan journey.',
      type: 'trip',
    ),
    _OnboardingPage(
      emoji: '🥗',
      title: 'Any dietary\nneeds?',
      subtitle: 'We\'ll flag restaurants that can accommodate you.',
      type: 'dietary',
    ),
    _OnboardingPage(
      emoji: '💴',
      title: 'What\'s your\nmeal budget?',
      subtitle: 'Per person, including drinks.',
      type: 'budget',
    ),
    _OnboardingPage(
      emoji: '🌶️',
      title: 'How adventurous\nare you?',
      subtitle:
          'Do you want easy foreigner-friendly spots, or are you ready to dive in?',
      type: 'comfort',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasOnboarded', true);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, top: 12),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Skip',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) {
                  return _buildPage(_pages[i]);
                },
              ),
            ),

            // Indicator + button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.divider,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Let\'s eat! 🍜'
                            : 'Continue',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(page.emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          Text(page.title, style: AppTextStyles.displaySmall),
          const SizedBox(height: 12),
          Text(
            page.subtitle,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          if (page.type == 'trip') _buildTripSelector(),
          if (page.type == 'dietary') _buildDietarySelector(),
          if (page.type == 'budget') _buildBudgetSelector(),
          if (page.type == 'comfort') _buildComfortSelector(),
        ],
      ),
    );
  }

  Widget _buildTripSelector() {
    final options = [
      ('first_time', '🌸', 'First time in Japan', 'I need lots of guidance'),
      ('returning', '🎌', 'Been before', 'I know the basics'),
      ('expat', '🏠', 'I live here', 'Help me discover hidden gems'),
    ];
    return Column(
      children: options.map((opt) {
        final (key, emoji, title, sub) = opt;
        final selected = _tripType == key;
        return _SelectionTile(
          emoji: emoji,
          title: title,
          subtitle: sub,
          selected: selected,
          onTap: () => setState(() => _tripType = key),
        );
      }).toList(),
    );
  }

  Widget _buildDietarySelector() {
    final options = [
      ('vegetarian', '🥦', 'Vegetarian'),
      ('vegan', '🌱', 'Vegan'),
      ('halal', '☪️', 'Halal'),
      ('allergies', '⚠️', 'Allergies / Intolerances'),
      ('no_pork', '🐷', 'No pork'),
      ('none', '✅', 'No restrictions'),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final (key, emoji, label) = opt;
        final selected = _dietaryNeeds.contains(key);
        return GestureDetector(
          onTap: () => setState(() {
            if (selected) {
              _dietaryNeeds.remove(key);
            } else {
              if (key == 'none') _dietaryNeeds.clear();
              _dietaryNeeds.add(key);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.divider,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBudgetSelector() {
    final options = [
      ('low', '💰', 'Under ¥1,500', 'Ramen, gyudon, convenience stores'),
      ('mid', '💰💰', '¥1,500–5,000', 'Izakayas, casual sushi, tonkatsu'),
      ('high', '💰💰💰', '¥5,000–15,000', 'Omakase, kaiseki, high-end'),
      ('any', '🎲', 'Surprise me', 'No preference'),
    ];
    return Column(
      children: options.map((opt) {
        final (key, emoji, title, sub) = opt;
        final selected = _budget == key;
        return _SelectionTile(
          emoji: emoji,
          title: title,
          subtitle: sub,
          selected: selected,
          onTap: () => setState(() => _budget = key),
        );
      }).toList(),
    );
  }

  Widget _buildComfortSelector() {
    final options = [
      ('easy', '😌', 'Keep it easy', 'English menus, card payment, walkable'),
      ('moderate', '🙂', 'Some adventure', 'I can point at a menu'),
      ('adventurous', '🔥', 'Full Japan mode', 'No English? Bring it on.'),
    ];
    return Column(
      children: options.map((opt) {
        final (key, emoji, title, sub) = opt;
        final selected = _comfort == key;
        return _SelectionTile(
          emoji: emoji,
          title: title,
          subtitle: sub,
          selected: selected,
          onTap: () => setState(() => _comfort = key),
        );
      }).toList(),
    );
  }
}

class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isIntro;
  final String? type;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.isIntro = false,
    this.type,
  });
}

class _SelectionTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: selected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
