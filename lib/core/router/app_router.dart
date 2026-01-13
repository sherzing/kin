import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/screens.dart';

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
        builder: (context, state) => const DailyDeckScreen(),
      ),
      GoRoute(
        path: AppRoutes.contacts,
        name: 'contacts',
        builder: (context, state) => const ContactListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'contactDetail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ContactDetailScreen(contactId: id);
            },
            routes: [
              GoRoute(
                path: 'interactions',
                name: 'contactInteractions',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return InteractionListScreen(contactId: id);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
