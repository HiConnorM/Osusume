import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/map/map_screen.dart';
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
      builder: (_, _) =>const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, _) =>const OnboardingScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (_, _, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, _) =>const HomeScreen(),
        ),
        GoRoute(
          path: '/map',
          builder: (_, _) =>const MapScreen(),
        ),
        GoRoute(
          path: '/saved',
          builder: (_, _) =>const SavedScreen(),
        ),
        GoRoute(
          path: '/translate',
          builder: (_, _) =>const MenuTranslationScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (_, _) =>const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/recommend',
      builder: (_, _) =>const RecommendationScreen(),
    ),
    GoRoute(
      path: '/restaurant/:id',
      builder: (_, state) {
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
      builder: (_, state) {
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
