import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/screens.dart';

/// Route paths for the app.
abstract final class AppRoutes {
  static const String home = '/';
  static const String contacts = '/contacts';
  static const String contactNew = '/contacts/new';
  static const String contactDetail = '/contacts/:id';
  static const String contactEdit = '/contacts/:id/edit';
  static const String contactInteractions = '/contacts/:id/interactions';
  static const String interactionNew = '/contacts/:id/interactions/new';
  static const String interactionEdit = '/contacts/:id/interactions/:interactionId/edit';
  static const String circles = '/circles';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String timeline = '/timeline';
}

/// Provider for the app router.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Home (Daily Deck) branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const DailyDeckScreen(),
              ),
            ],
          ),
          // Contacts branch
          StatefulShellBranch(
            routes: [
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
                        routes: [
                          GoRoute(
                            path: 'new',
                            name: 'interactionNew',
                            builder: (context, state) {
                              final contactId = state.pathParameters['id']!;
                              return InteractionEditorScreen(
                                contactId: contactId,
                              );
                            },
                          ),
                          GoRoute(
                            path: ':interactionId/edit',
                            name: 'interactionEdit',
                            builder: (context, state) {
                              final contactId = state.pathParameters['id']!;
                              final interactionId =
                                  state.pathParameters['interactionId']!;
                              return InteractionEditorScreen(
                                contactId: contactId,
                                interactionId: interactionId,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Search branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                name: 'search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
        ],
      ),
      // Settings is outside the shell (full screen)
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      // Circles management
      GoRoute(
        path: AppRoutes.circles,
        name: 'circles',
        builder: (context, state) => const CircleListScreen(),
      ),
      // Timeline view
      GoRoute(
        path: AppRoutes.timeline,
        name: 'timeline',
        builder: (context, state) => const TimelineScreen(),
      ),
      // Contact form routes (outside shell for modal-like experience)
      GoRoute(
        path: AppRoutes.contactNew,
        name: 'contactNew',
        builder: (context, state) => const ContactFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.contactEdit,
        name: 'contactEdit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ContactFormScreen(contactId: id);
        },
      ),
    ],
  );
});
