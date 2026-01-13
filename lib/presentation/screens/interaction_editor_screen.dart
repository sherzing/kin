import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../core/services/haptic_service.dart';
import '../../data/database/database.dart';
import '../../data/database/tables/interactions.dart';
import '../widgets/widgets.dart';

/// Screen for creating or editing an interaction.
class InteractionEditorScreen extends ConsumerStatefulWidget {
  const InteractionEditorScreen({
    super.key,
    required this.contactId,
    this.interactionId,
  });

  final String contactId;
  final String? interactionId;

  bool get isEditing => interactionId != null;

  @override
  ConsumerState<InteractionEditorScreen> createState() =>
      _InteractionEditorScreenState();
}

class _InteractionEditorScreenState
    extends ConsumerState<InteractionEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  InteractionType _selectedType = InteractionType.call;
  DateTime _happenedAt = DateTime.now();
  bool _isPreparation = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _initializeForEdit(Interaction interaction) async {
    if (_isInitialized) return;
    _isInitialized = true;

    _contentController.text = interaction.content ?? '';
    _selectedType = InteractionType.values.firstWhere(
      (t) => t.name == interaction.type,
      orElse: () => InteractionType.call,
    );
    _happenedAt =
        DateTime.fromMillisecondsSinceEpoch(interaction.happenedAt * 1000);
    _isPreparation = interaction.isPreparation;
    setState(() {});
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _happenedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      HapticService.selectionClick();
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_happenedAt),
      );
      if (time != null) {
        HapticService.selectionClick();
        setState(() {
          _happenedAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _save() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(interactionNotifierProvider.notifier);

      if (widget.isEditing) {
        await notifier.update(
          widget.interactionId!,
          contactId: widget.contactId,
          type: _selectedType,
          content: _contentController.text.trim().isEmpty
              ? null
              : _contentController.text.trim(),
          isPreparation: _isPreparation,
          happenedAt: _happenedAt,
        );
      } else {
        await notifier.create(
          contactId: widget.contactId,
          type: _selectedType,
          content: _contentController.text.trim().isEmpty
              ? null
              : _contentController.text.trim(),
          isPreparation: _isPreparation,
          happenedAt: _happenedAt,
        );
      }

      // Haptic feedback on successful save
      HapticService.mediumImpact();

      if (mounted) {
        context.pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      final interactionAsync =
          ref.watch(interactionProvider(widget.interactionId!));

      return interactionAsync.when(
        data: (interaction) {
          if (interaction == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Not Found')),
              body: const Center(child: Text('Interaction not found')),
            );
          }
          _initializeForEdit(interaction);
          return _buildForm();
        },
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Loading...')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(child: Text('Error: $error')),
        ),
      );
    }

    return _buildForm();
  }

  Widget _buildForm() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Interaction' : 'Log Interaction'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preparation toggle
            _PreparationToggle(
              isPreparation: _isPreparation,
              onChanged: (value) => setState(() => _isPreparation = value),
            ),
            const SizedBox(height: 24),

            // Type selector
            Text(
              'Type',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _TypeSelector(
              selectedType: _selectedType,
              onChanged: (type) => setState(() => _selectedType = type),
            ),
            const SizedBox(height: 24),

            // Date/Time picker
            Text(
              'When',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _DateTimePicker(
              dateTime: _happenedAt,
              onTap: _pickDate,
            ),
            const SizedBox(height: 24),

            // Content field with Markdown editor
            Text(
              _isPreparation ? 'Preparation Notes' : 'Notes',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            MarkdownEditor(
              controller: _contentController,
              hintText: _isPreparation
                  ? 'What do you want to talk about?'
                  : 'How did it go?',
              minLines: 5,
              maxLines: 12,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreparationToggle extends StatelessWidget {
  const _PreparationToggle({
    required this.isPreparation,
    required this.onChanged,
  });

  final bool isPreparation;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Reflection',
              icon: Icons.history,
              isSelected: !isPreparation,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Preparation',
              icon: Icons.upcoming,
              isSelected: isPreparation,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  final InteractionType selectedType;
  final ValueChanged<InteractionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: InteractionType.values.map((type) {
        final isSelected = type == selectedType;
        return ChoiceChip(
          label: Text(_getTypeLabel(type)),
          avatar: Icon(
            _getTypeIcon(type),
            size: 18,
          ),
          selected: isSelected,
          onSelected: (_) => onChanged(type),
        );
      }).toList(),
    );
  }

  String _getTypeLabel(InteractionType type) {
    switch (type) {
      case InteractionType.call:
        return 'Call';
      case InteractionType.meetup:
        return 'Meetup';
      case InteractionType.message:
        return 'Message';
      case InteractionType.email:
        return 'Email';
      case InteractionType.gift:
        return 'Gift';
    }
  }

  IconData _getTypeIcon(InteractionType type) {
    switch (type) {
      case InteractionType.call:
        return Icons.call;
      case InteractionType.meetup:
        return Icons.people;
      case InteractionType.message:
        return Icons.chat;
      case InteractionType.email:
        return Icons.email;
      case InteractionType.gift:
        return Icons.card_giftcard;
    }
  }
}

class _DateTimePicker extends StatelessWidget {
  const _DateTimePicker({
    required this.dateTime,
    required this.onTap,
  });

  final DateTime dateTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(dateTime),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  _formatTime(dateTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.edit,
              size: 16,
              color: Theme.of(context).colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return 'Yesterday';
    }
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
