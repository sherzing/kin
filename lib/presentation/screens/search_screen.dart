import 'package:flutter/material.dart';

/// Screen for searching contacts, interactions, and circles.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: const Center(
        child: Text('Search for contacts and interactions'),
      ),
    );
  }
}
