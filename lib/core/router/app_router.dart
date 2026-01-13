import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Route paths for the app.
abstract final class AppRoutes {
  static const String home = '/';
  static const String contacts = '/contacts';
  static const String contactDetail = '/contacts/:id';
  static const String contactInteractions = '/contacts/:id/interactions';
  static const String search = '/search';
  static const String settings = '/settings';
}

/// Provider for the app router.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const _PlaceholderScreen(title: 'Daily Deck'),
      ),
      GoRoute(
        path: AppRoutes.contacts,
        name: 'contacts',
        builder: (context, state) => const _PlaceholderScreen(title: 'Contacts'),
        routes: [
          GoRoute(
            path: ':id',
            name: 'contactDetail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return _PlaceholderScreen(title: 'Contact: $id');
            },
            routes: [
              GoRoute(
                path: 'interactions',
                name: 'contactInteractions',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return _PlaceholderScreen(title: 'Interactions: $id');
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) => const _PlaceholderScreen(title: 'Search'),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const _PlaceholderScreen(title: 'Settings'),
      ),
    ],
  );
});

/// Temporary placeholder screen for routes.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
