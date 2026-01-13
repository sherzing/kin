import 'package:flutter/material.dart';

import '../../data/database/database.dart';
import 'health_ring.dart';
import 'nudge_sheet.dart';

/// A card displaying a contact in the Daily Deck.
///
/// Shows:
/// - Avatar with health ring
/// - Contact name
/// - Last contacted date
/// - Days overdue indicator
/// - Nudge button for quick contact
class DailyDeckCard extends StatelessWidget {
  const DailyDeckCard({
    super.key,
    required this.contact,
    this.onTap,
    this.showNudgeButton = true,
  });

  final Contact contact;
  final VoidCallback? onTap;
  final bool showNudgeButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar with health ring and Hero transition
              Hero(
                tag: 'contact-avatar-${contact.id}',
                child: HealthRing(
                  contact: contact,
                  size: 96,
                  strokeWidth: 4,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      _getInitials(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Contact name
              Text(
                contact.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Last contacted date
              Text(
                _getLastContactedText(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 4),

              // Overdue indicator
              _OverdueChip(contact: contact),

              // Nudge button
              if (showNudgeButton) ...[
                const SizedBox(height: 16),
                _NudgeButton(contact: contact),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    final parts = contact.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
  }

  String _getLastContactedText() {
    if (contact.lastContactedAt == null) {
      return 'Never contacted';
    }

    final lastContacted =
        DateTime.fromMillisecondsSinceEpoch(contact.lastContactedAt! * 1000);
    final now = DateTime.now();
    final difference = now.difference(lastContacted);

    if (difference.inDays == 0) {
      return 'Last contacted today';
    } else if (difference.inDays == 1) {
      return 'Last contacted yesterday';
    } else if (difference.inDays < 7) {
      return 'Last contacted ${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return 'Last contacted ${weeks} ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = difference.inDays ~/ 30;
      return 'Last contacted ${months} ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = difference.inDays ~/ 365;
      return 'Last contacted ${years} ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}

/// A chip showing how overdue a contact is.
class _OverdueChip extends StatelessWidget {
  const _OverdueChip({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final overdueData = _calculateOverdue();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: overdueData.color.withAlpha(51), // 20% opacity
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        overdueData.text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: overdueData.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _OverdueData _calculateOverdue() {
    if (contact.lastContactedAt == null) {
      return _OverdueData(
        text: 'Needs attention',
        color: Colors.red.shade700,
      );
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final lastContact = contact.lastContactedAt!;
    final cadenceSeconds = contact.cadenceDays * 86400;
    final dueDate = lastContact + cadenceSeconds;
    final overdueSeconds = now - dueDate;

    if (overdueSeconds <= 0) {
      // Not overdue
      final daysUntilDue = (-overdueSeconds) ~/ 86400;
      if (daysUntilDue == 0) {
        return _OverdueData(
          text: 'Due today',
          color: Colors.orange.shade700,
        );
      }
      return _OverdueData(
        text: 'Due in $daysUntilDue ${daysUntilDue == 1 ? 'day' : 'days'}',
        color: Colors.green.shade700,
      );
    }

    final overdueDays = overdueSeconds ~/ 86400;
    if (overdueDays == 0) {
      return _OverdueData(
        text: 'Due today',
        color: Colors.orange.shade700,
      );
    } else if (overdueDays == 1) {
      return _OverdueData(
        text: '1 day overdue',
        color: Colors.orange.shade700,
      );
    } else if (overdueDays < 7) {
      return _OverdueData(
        text: '$overdueDays days overdue',
        color: Colors.orange.shade700,
      );
    } else if (overdueDays < 30) {
      final weeks = overdueDays ~/ 7;
      return _OverdueData(
        text: '$weeks ${weeks == 1 ? 'week' : 'weeks'} overdue',
        color: Colors.red.shade700,
      );
    } else {
      final months = overdueDays ~/ 30;
      return _OverdueData(
        text: '$months ${months == 1 ? 'month' : 'months'} overdue',
        color: Colors.red.shade700,
      );
    }
  }
}

class _OverdueData {
  const _OverdueData({required this.text, required this.color});

  final String text;
  final Color color;
}

/// A button to quickly reach out to a contact.
class _NudgeButton extends StatelessWidget {
  const _NudgeButton({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasContactInfo =
        (contact.phone != null && contact.phone!.isNotEmpty) ||
            (contact.email != null && contact.email!.isNotEmpty);

    return FilledButton.tonalIcon(
      onPressed: () => showNudgeSheet(context, contact),
      icon: const Icon(Icons.send, size: 18),
      label: Text(hasContactInfo ? 'Reach Out' : 'Add Contact Info'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: theme.textTheme.labelLarge,
      ),
    );
  }
}
