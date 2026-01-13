import 'package:flutter/material.dart';

/// Screen displaying interaction history for a contact.
class InteractionListScreen extends StatelessWidget {
  const InteractionListScreen({
    super.key,
    required this.contactId,
  });

  final String contactId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactions'),
      ),
      body: Center(
        child: Text('Interactions for contact: $contactId'),
      ),
    );
  }
}
