import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/recommendations/recommendation_screen.dart';
import '../../features/restaurants/restaurant_detail_screen.dart';
import '../../features/menu_translation/menu_translation_screen.dart';
import '../../features/reservations/reservation_screen.dart';
import '../../features/saved/saved_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../shared/widgets/main_shell.dart';
import '../../core/models/restaurant.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/saved',
          builder: (context, state) => const SavedScreen(),
        ),
        GoRoute(
          path: '/translate',
          builder: (context, state) => const MenuTranslationScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/recommend',
      builder: (context, state) => const RecommendationScreen(),
    ),
    GoRoute(
      path: '/restaurant/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final restaurant = MockRestaurants.all.firstWhere(
          (r) => r.id == id,
          orElse: () => MockRestaurants.all.first,
        );
        return RestaurantDetailScreen(restaurant: restaurant);
      },
    ),
    GoRoute(
      path: '/reserve/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final restaurant = MockRestaurants.all.firstWhere(
          (r) => r.id == id,
          orElse: () => MockRestaurants.all.first,
        );
        return ReservationScreen(restaurant: restaurant);
      },
    ),
  ],
);
