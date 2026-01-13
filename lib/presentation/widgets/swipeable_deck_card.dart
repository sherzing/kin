import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../core/services/haptic_service.dart';
import '../../data/database/database.dart';
import 'daily_deck_card.dart';

/// A swipeable wrapper for DailyDeckCard that handles deck actions.
///
/// - Swipe right: Quick log (mark as contacted now)
/// - Swipe left: Open snooze dialog
class SwipeableDeckCard extends ConsumerStatefulWidget {
  const SwipeableDeckCard({
    super.key,
    required this.contact,
    this.onTap,
  });

  final Contact contact;
  final VoidCallback? onTap;

  @override
  ConsumerState<SwipeableDeckCard> createState() => _SwipeableDeckCardState();
}

class _SwipeableDeckCardState extends ConsumerState<SwipeableDeckCard>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  bool _isDismissed = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: 0.9 + (_fadeAnimation.value * 0.1),
            child: child,
          ),
        );
      },
      child: Dismissible(
        key: Key('deck-card-${widget.contact.id}'),
        background: _buildQuickLogBackground(theme),
        secondaryBackground: _buildSnoozeBackground(theme),
        // Spring-like animation with longer duration
        movementDuration: const Duration(milliseconds: 300),
        dismissThresholds: const {
          DismissDirection.startToEnd: 0.3,
          DismissDirection.endToStart: 0.3,
        },
        confirmDismiss: (direction) async {
          if (_isProcessing || _isDismissed) return false;

          if (direction == DismissDirection.startToEnd) {
            // Swipe right: Quick log
            await _handleQuickLog();
            _isDismissed = true;
            await _fadeController.forward();
            return true; // Remove card
          } else {
            // Swipe left: Show snooze dialog
            final snoozed = await _showSnoozeDialog();
            if (snoozed) {
              _isDismissed = true;
              await _fadeController.forward();
            }
            return snoozed; // Remove if snoozed
          }
        },
        child: DailyDeckCard(
          contact: widget.contact,
          onTap: widget.onTap,
        ),
      ),
    );
  }

  Widget _buildQuickLogBackground(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade600,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 24),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 32),
          SizedBox(width: 12),
          Text(
            'Quick Log',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnoozeBackground(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade600,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Snooze',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 12),
          Icon(Icons.snooze, color: Colors.white, size: 32),
        ],
      ),
    );
  }

  Future<void> _handleQuickLog() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final notifier = ref.read(dailyDeckNotifierProvider.notifier);
      await notifier.quickLog(widget.contact.id);

      // Haptic feedback on successful quick log
      HapticService.mediumImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged contact with ${widget.contact.name}'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Add Note',
              onPressed: () {
                // Navigate to interaction editor for more details
                // This will be implemented in kin-61v
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log contact: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool> _showSnoozeDialog() async {
    final presets = ref.read(snoozePresetsProvider);

    final selectedDays = await showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _SnoozeSheet(
        contactName: widget.contact.name,
        presets: presets,
      ),
    );

    if (selectedDays == null) return false;

    setState(() => _isProcessing = true);

    try {
      final notifier = ref.read(dailyDeckNotifierProvider.notifier);
      await notifier.snoozeForDays(widget.contact.id, selectedDays);

      // Haptic feedback on successful snooze
      HapticService.selectionClick();

      if (mounted) {
        final preset = presets.firstWhere(
          (p) => p.days == selectedDays,
          orElse: () => SnoozePreset(days: selectedDays, label: '$selectedDays days'),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Snoozed ${widget.contact.name} for ${preset.label}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to snooze: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

/// Bottom sheet for selecting snooze duration.
class _SnoozeSheet extends StatelessWidget {
  const _SnoozeSheet({
    required this.contactName,
    required this.presets,
  });

  final String contactName;
  final List<SnoozePreset> presets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                      const Icon(Icons.snooze, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Snooze',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Remind me about $contactName later',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),

            // Preset options
            ...presets.map((preset) => ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(preset.label),
                  onTap: () => Navigator.of(context).pop(preset.days),
                )),

            // Custom option
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Custom date...'),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null && context.mounted) {
                  HapticService.selectionClick();
                  final days = picked.difference(DateTime.now()).inDays;
                  Navigator.of(context).pop(days);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
