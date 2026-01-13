import 'package:flutter/material.dart';

/// Screen displaying detailed information about a contact.
class ContactDetailScreen extends StatelessWidget {
  const ContactDetailScreen({
    super.key,
    required this.contactId,
  });

  final String contactId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
      ),
      body: Center(
        child: Text('Contact: $contactId'),
      ),
    );
  }
}
