import 'package:flutter/material.dart';

/// Screen displaying the list of all contacts.
class ContactListScreen extends StatelessWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: const Center(
        child: Text('Your contacts will appear here'),
      ),
    );
  }
}
