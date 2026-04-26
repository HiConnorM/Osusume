import 'package:flutter/material.dart';
import '../../core/models/restaurant.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/restaurant_card.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _lists = [
    _SavedList(
      name: 'Tokyo Trip',
      emoji: '🗼',
      restaurants: MockRestaurants.all.take(3).toList(),
    ),
    _SavedList(
      name: 'Ramen spots',
      emoji: '🍜',
      restaurants: [MockRestaurants.all[0], MockRestaurants.all[4]],
    ),
    _SavedList(
      name: 'Date night',
      emoji: '🥂',
      restaurants: [MockRestaurants.all[1], MockRestaurants.all[3]],
    ),
    _SavedList(
      name: 'Must try',
      emoji: '⭐',
      restaurants: MockRestaurants.all,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _createList,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: AppTextStyles.labelMedium,
          unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          tabs: const [
            Tab(text: 'Lists'),
            Tab(text: 'All saved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListsTab(),
          _buildAllSavedTab(),
        ],
      ),
    );
  }

  Widget _buildListsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ..._lists.map((list) => _ListCard(
              savedList: list,
              onTap: () {},
            )),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _createList,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Create new list'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildAllSavedTab() {
    final all = MockRestaurants.all;
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: all.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: RestaurantCard(restaurant: all[i], horizontal: true),
      ),
    );
  }

  void _createList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New list', style: AppTextStyles.headingLarge),
            const SizedBox(height: 20),
            const TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'List name (e.g. "Kyoto spots")',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Create list'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedList {
  final String name;
  final String emoji;
  final List<Restaurant> restaurants;

  const _SavedList({
    required this.name,
    required this.emoji,
    required this.restaurants,
  });
}

class _ListCard extends StatelessWidget {
  final _SavedList savedList;
  final VoidCallback onTap;

  const _ListCard({required this.savedList, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  savedList.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(savedList.name, style: AppTextStyles.labelLarge),
                  Text(
                    '${savedList.restaurants.length} ${savedList.restaurants.length == 1 ? 'place' : 'places'}',
                    style: AppTextStyles.bodySmall,
                  ),
                  if (savedList.restaurants.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      savedList.restaurants.take(3).map((r) => r.nameEn).join(', '),
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
