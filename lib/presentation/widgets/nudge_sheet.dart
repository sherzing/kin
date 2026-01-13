import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/database/database.dart';

/// Message templates for nudging contacts.
const List<String> _messageTemplates = [
  "Hey! Just thinking of you. How have you been?",
  "Hi! It's been a while. Would love to catch up!",
  "Hey there! Hope you're doing well. Let's connect soon!",
  "Just wanted to say hi and see how things are going!",
];

/// Bottom sheet for nudging a contact.
///
/// Provides quick options to reach out via:
/// - Phone call
/// - Text message (SMS)
/// - Email
///
/// Includes pre-filled message templates for convenience.
class NudgeSheet extends StatelessWidget {
  const NudgeSheet({
    super.key,
    required this.contact,
  });

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhone = contact.phone != null && contact.phone!.isNotEmpty;
    final hasEmail = contact.email != null && contact.email!.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.send, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Reach out to ${contact.name}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (!hasPhone && !hasEmail) ...[
                    const SizedBox(height: 8),
                    Text(
                      'No contact info available. Add phone or email to enable nudging.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),

            // Contact options
            if (hasPhone) ...[
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Call'),
                subtitle: Text(contact.phone!),
                onTap: () => _launchPhone(context, contact.phone!),
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Send Text Message'),
                subtitle: Text(contact.phone!),
                onTap: () => _showMessageTemplates(context, isEmail: false),
              ),
            ],

            if (hasEmail)
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Send Email'),
                subtitle: Text(contact.email!),
                onTap: () => _showMessageTemplates(context, isEmail: true),
              ),

            if (!hasPhone && !hasEmail)
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Add contact info'),
                subtitle: const Text('Edit contact to add phone or email'),
                onTap: () => Navigator.of(context).pop('edit'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        if (context.mounted) Navigator.of(context).pop('called');
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open phone app')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showMessageTemplates(BuildContext context, {required bool isEmail}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _MessageTemplateSheet(
        contact: contact,
        isEmail: isEmail,
      ),
    ).then((result) {
      if (result != null && context.mounted) {
        Navigator.of(context).pop(result);
      }
    });
  }
}

/// Sheet for selecting or customizing a message template.
class _MessageTemplateSheet extends StatefulWidget {
  const _MessageTemplateSheet({
    required this.contact,
    required this.isEmail,
  });

  final Contact contact;
  final bool isEmail;

  @override
  State<_MessageTemplateSheet> createState() => _MessageTemplateSheetState();
}

class _MessageTemplateSheetState extends State<_MessageTemplateSheet> {
  final _messageController = TextEditingController();
  String? _selectedTemplate;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEmail ? 'Compose Email' : 'Send Message',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Template chips
            Text(
              'Quick templates:',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _messageTemplates.asMap().entries.map((entry) {
                final isSelected = _selectedTemplate == entry.value;
                return ChoiceChip(
                  label: Text('Template ${entry.key + 1}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTemplate = entry.value;
                        _messageController.text = entry.value;
                      } else {
                        _selectedTemplate = null;
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Message input
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
                hintText: 'Type your message...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                    onPressed: () => _copyMessage(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Send'),
                    onPressed: () => _sendMessage(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyMessage(BuildContext context) {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No message to copy')),
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied to clipboard')),
    );
  }

  Future<void> _sendMessage(BuildContext context) async {
    final message = _messageController.text.trim();

    try {
      Uri uri;
      if (widget.isEmail) {
        uri = Uri(
          scheme: 'mailto',
          path: widget.contact.email,
          queryParameters: message.isNotEmpty ? {'body': message} : null,
        );
      } else {
        uri = Uri(
          scheme: 'sms',
          path: widget.contact.phone,
          queryParameters: message.isNotEmpty ? {'body': message} : null,
        );
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        if (context.mounted) {
          Navigator.of(context).pop('sent');
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isEmail
                    ? 'Could not open email app'
                    : 'Could not open messaging app',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

/// Shows the nudge sheet for a contact.
///
/// Returns a string indicating the action taken, or null if dismissed.
Future<String?> showNudgeSheet(BuildContext context, Contact contact) {
  return showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => NudgeSheet(contact: contact),
  );
}
