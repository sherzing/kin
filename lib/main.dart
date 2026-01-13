import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/router.dart';
import 'core/theme/theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: KinApp(),
    ),
  );
}

/// The root widget for the Kin app.
class KinApp extends ConsumerWidget {
  const KinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Kin',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
