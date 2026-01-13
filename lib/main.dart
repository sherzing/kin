import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: KinApp(),
    ),
  );
}

/// The root widget for the Kin app.
class KinApp extends StatelessWidget {
  const KinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kin',
      theme: AppTheme.light,
      home: const PlaceholderHomePage(),
    );
  }
}

/// Temporary placeholder home page.
/// Will be replaced with Daily Deck screen.
class PlaceholderHomePage extends StatelessWidget {
  const PlaceholderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kin'),
      ),
      body: const Center(
        child: Text('Welcome to Kin'),
      ),
    );
  }
}
