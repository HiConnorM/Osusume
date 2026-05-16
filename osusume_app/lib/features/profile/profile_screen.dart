import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildPreferencesCard(context),
                const SizedBox(height: 16),
                _buildSection('App', [
                  _SettingsRow(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    trailing: Switch(
                      value: true,
                      onChanged: (_) {},
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                  _SettingsRow(
                    icon: Icons.language_rounded,
                    label: 'Language',
                    value: 'English',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location services',
                    value: 'Enabled',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSection('Osusume Plus', [
                  _PremiumCard(),
                ]),
                const SizedBox(height: 16),
                _buildSection('Help & Legal', [
                  _SettingsRow(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & FAQ',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy policy',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.description_outlined,
                    label: 'Terms of service',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.info_outline_rounded,
                    label: 'About',
                    value: 'v1.0.0',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSection('Account', [
                  _SettingsRow(
                    icon: Icons.logout_rounded,
                    label: 'Reset onboarding',
                    iconColor: AppColors.error,
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('hasOnboarded');
                      if (context.mounted) context.go('/onboarding');
                    },
                  ),
                ]),
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/app_icon.png',
                        width: 32,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 6),
                      Text('Osusume!', style: AppTextStyles.headingSmall.copyWith(color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text(
                        'Made with ❤️ for Japan travelers',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildHeader() {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      expandedHeight: 160,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('👤', style: TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Traveler', style: AppTextStyles.headingMedium),
                          Text(
                            'Japan adventurer · Beginner',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Edit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context) {
    final prefs = [
      ('🍜', 'Ramen', 'Favorite'),
      ('🥗', 'No shellfish', 'Allergy'),
      ('💰💰', '¥1,500–5,000', 'Budget'),
      ('😌', 'Easy', 'Comfort'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Your preferences', style: AppTextStyles.labelLarge),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/onboarding'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: prefs.map((p) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(p.$1, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(
                        p.$2,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(p.$3, style: AppTextStyles.caption, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              letterSpacing: 1.2,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: children.asMap().entries.map((e) {
              final isLast = e.key == children.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast) const Divider(height: 1, indent: 52),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 20, color: iconColor ?? AppColors.textSecondary),
      title: Text(label, style: AppTextStyles.bodyMedium),
      trailing: trailing ??
          (value != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(value!, style: AppTextStyles.bodySmall),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded,
                        size: 18, color: AppColors.textTertiary),
                  ],
                )
              : onTap != null
                  ? const Icon(Icons.chevron_right_rounded,
                      size: 18, color: AppColors.textTertiary)
                  : null),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'Osusume Plus',
                style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Unlimited translations · Full AI recommendations · Trip planner · Allergy cards',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Try free for 7 days',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '\$5.99/mo after',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
