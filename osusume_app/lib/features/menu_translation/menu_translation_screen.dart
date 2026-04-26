import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class MenuTranslationScreen extends StatefulWidget {
  const MenuTranslationScreen({super.key});

  @override
  State<MenuTranslationScreen> createState() => _MenuTranslationScreenState();
}

class _MenuTranslationScreenState extends State<MenuTranslationScreen> {
  bool _isTranslating = false;
  bool _hasResult = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);
    if (file != null) {
      setState(() {
        _isTranslating = true;
      });
      // Simulate translation
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isTranslating = false;
          _hasResult = true;
        });
      }
    }
  }

  void _reset() {
    setState(() {
      _isTranslating = false;
      _hasResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Menu Translator'),
        actions: [
          if (_hasResult)
            TextButton(
              onPressed: _reset,
              child: const Text('New photo'),
            ),
        ],
      ),
      body: _hasResult
          ? _buildResultView()
          : _isTranslating
              ? _buildLoadingView()
              : _buildPickerView(context),
    );
  }

  Widget _buildPickerView(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Translate any menu', style: AppTextStyles.displaySmall),
            const SizedBox(height: 8),
            Text(
              'Take a photo or upload one. We\'ll translate every dish, explain ingredients, and flag allergens.',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 36),

            // Camera button (primary)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_rounded, size: 22),
                label: const Text('Take a photo'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Gallery button (secondary)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_rounded, size: 22),
                label: const Text('Choose from gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // What you get section
            Text('What you\'ll get', style: AppTextStyles.headingSmall),
            const SizedBox(height: 16),
            ..._features.map((f) => _FeatureRow(emoji: f.$1, text: f.$2)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text('Translating your menu...', style: AppTextStyles.headingSmall),
          const SizedBox(height: 8),
          Text(
            'Reading characters and identifying dishes',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        // Translation complete banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.tagGreen,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Text('✅', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Translation complete',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.tagGreenText,
                      ),
                    ),
                    Text(
                      '8 dishes found · 2 allergen warnings',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.tagGreenText.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text('Translated Menu', style: AppTextStyles.headingSmall),
        const SizedBox(height: 14),

        // Mock translated dishes
        ..._mockDishes.map((d) => _DishCard(dish: d)),

        const SizedBox(height: 24),

        // Safe picks section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⭐ Safe picks for foreigners',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 10),
              Text(
                'Based on your profile (no shellfish, beginner), we suggest:',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 10),
              ..._mockDishes
                  .where((d) => d.isSafePick)
                  .map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(d.nameEn, style: AppTextStyles.labelMedium),
                          ],
                        ),
                      )),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // How to order
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How to order', style: AppTextStyles.headingSmall),
              const SizedBox(height: 10),
              const _PhraseRow(
                jp: 'これをください',
                romaji: 'Kore wo kudasai',
                en: '"I\'ll have this one" — point at menu',
              ),
              const _PhraseRow(
                jp: 'アレルギーがあります',
                romaji: 'Arerugī ga arimasu',
                en: '"I have allergies"',
              ),
              const _PhraseRow(
                jp: 'えびなしで',
                romaji: 'Ebi nashi de',
                en: '"Without shrimp"',
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const _features = [
    ('🈳', 'Japanese → English translation'),
    ('🥗', 'Ingredients explained simply'),
    ('⚠️', 'Allergen flags (shellfish, pork, nuts...)'),
    ('🌶️', 'Spice level indicators'),
    ('⭐', 'Safe picks based on your profile'),
    ('🗣️', 'How to order in Japanese'),
  ];

  static const _mockDishes = [
    _Dish(
      nameJa: '醤油ラーメン',
      nameEn: 'Soy Sauce Ramen',
      description: 'Chicken and dashi broth with soy sauce tare, noodles, chashu pork, bamboo shoots, and nori.',
      price: '¥980',
      allergens: ['Wheat', 'Soy', 'Pork'],
      spiceLevel: 0,
      isSafePick: true,
    ),
    _Dish(
      nameJa: '海老天ぷら',
      nameEn: 'Shrimp Tempura',
      description: 'Crispy battered shrimp served with dipping sauce and grated daikon.',
      price: '¥1,200',
      allergens: ['Shellfish', 'Wheat', 'Egg'],
      spiceLevel: 0,
      isSafePick: false,
    ),
    _Dish(
      nameJa: '唐揚げ定食',
      nameEn: 'Karaage Set Meal',
      description: 'Deep-fried marinated chicken thighs with rice, miso soup, pickles, and salad.',
      price: '¥1,080',
      allergens: ['Wheat', 'Soy'],
      spiceLevel: 0,
      isSafePick: true,
    ),
    _Dish(
      nameJa: '麻婆豆腐',
      nameEn: 'Mapo Tofu',
      description: 'Silken tofu in a spicy Sichuan-style sauce with minced pork and chili oil.',
      price: '¥880',
      allergens: ['Soy', 'Pork'],
      spiceLevel: 3,
      isSafePick: false,
    ),
  ];
}

class _Dish {
  final String nameJa;
  final String nameEn;
  final String description;
  final String price;
  final List<String> allergens;
  final int spiceLevel;
  final bool isSafePick;

  const _Dish({
    required this.nameJa,
    required this.nameEn,
    required this.description,
    required this.price,
    required this.allergens,
    required this.spiceLevel,
    required this.isSafePick,
  });
}

class _DishCard extends StatelessWidget {
  final _Dish dish;

  const _DishCard({required this.dish});

  @override
  Widget build(BuildContext context) {
    final hasAllergen = dish.allergens.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasAllergen ? AppColors.warning.withOpacity(0.3) : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dish.nameEn, style: AppTextStyles.labelLarge),
                    Text(
                      dish.nameJa,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(dish.price, style: AppTextStyles.labelMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(dish.description, style: AppTextStyles.bodySmall),
          if (dish.spiceLevel > 0 || hasAllergen) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: [
                if (dish.spiceLevel > 0)
                  _chip(
                    '🌶️ ${'🔥' * dish.spiceLevel}',
                    AppColors.tagOrangeText,
                    AppColors.tagOrange,
                  ),
                ...dish.allergens.map(
                  (a) => _chip('⚠️ $a', AppColors.warning, AppColors.warning.withOpacity(0.12)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, Color text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: text, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String emoji;
  final String text;

  const _FeatureRow({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(text, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _PhraseRow extends StatelessWidget {
  final String jp;
  final String romaji;
  final String en;

  const _PhraseRow({
    required this.jp,
    required this.romaji,
    required this.en,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(jp, style: AppTextStyles.labelLarge),
          Text(romaji, style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          )),
          Text(en, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
