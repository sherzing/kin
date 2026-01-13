import 'package:flutter/material.dart';

/// The Daily Deck screen - home screen showing prioritized contacts.
///
/// Displays contacts that are due for contact based on their cadence.
class DailyDeckScreen extends StatelessWidget {
  const DailyDeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Deck'),
      ),
      body: const Center(
        child: Text('Your daily contacts will appear here'),
      ),
    );
  }
}
