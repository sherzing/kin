import 'package:flutter/material.dart';

/// A reusable empty state illustration component.
///
/// Provides a consistent look for empty states across the app with:
/// - An animated or static illustration using icons
/// - A title message
/// - A subtitle with more context
/// - Optional action button(s)
class EmptyStateIllustration extends StatelessWidget {
  const EmptyStateIllustration({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.secondaryIcon,
    this.decorationColor,
  });

  /// Main icon for the illustration
  final IconData icon;

  /// Optional secondary icon for decoration
  final IconData? secondaryIcon;

  /// Title text
  final String title;

  /// Subtitle/description text
  final String subtitle;

  /// Optional action button label
  final String? actionLabel;

  /// Optional action callback
  final VoidCallback? onAction;

  /// Optional custom decoration color
  final Color? decorationColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = decorationColor ?? theme.colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration area
            _IllustrationStack(
              icon: icon,
              secondaryIcon: secondaryIcon,
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),

            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A decorative stack of icons for the illustration.
class _IllustrationStack extends StatelessWidget {
  const _IllustrationStack({
    required this.icon,
    this.secondaryIcon,
    required this.primaryColor,
  });

  final IconData icon;
  final IconData? secondaryIcon;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withAlpha(25),
            ),
          ),

          // Inner circle
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withAlpha(51),
            ),
          ),

          // Main icon
          Icon(
            icon,
            size: 48,
            color: primaryColor,
          ),

          // Secondary decorative icon
          if (secondaryIcon != null)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(76),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  secondaryIcon,
                  size: 20,
                  color: primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Pre-defined empty state for "all caught up" scenario.
class AllCaughtUpIllustration extends StatelessWidget {
  const AllCaughtUpIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateIllustration(
      icon: Icons.celebration_outlined,
      secondaryIcon: Icons.check_circle,
      title: "You're all caught up!",
      subtitle:
          'No contacts are due for a check-in right now.\nTake a moment to relax!',
      decorationColor: Colors.green,
    );
  }
}

/// Pre-defined empty state for no contacts.
class NoContactsIllustration extends StatelessWidget {
  const NoContactsIllustration({
    super.key,
    this.onAddContact,
  });

  final VoidCallback? onAddContact;

  @override
  Widget build(BuildContext context) {
    return EmptyStateIllustration(
      icon: Icons.people_outline,
      secondaryIcon: Icons.favorite,
      title: 'Start building your network',
      subtitle:
          'Add the people you want to stay in touch with.\nKin will help you nurture those relationships.',
      actionLabel: 'Add Your First Contact',
      onAction: onAddContact,
    );
  }
}

/// Pre-defined empty state for no interactions.
class NoInteractionsIllustration extends StatelessWidget {
  const NoInteractionsIllustration({
    super.key,
    this.onLogInteraction,
  });

  final VoidCallback? onLogInteraction;

  @override
  Widget build(BuildContext context) {
    return EmptyStateIllustration(
      icon: Icons.chat_bubble_outline,
      secondaryIcon: Icons.edit_note,
      title: 'No interactions yet',
      subtitle:
          'Log your conversations and meetups\nto keep track of your relationship.',
      actionLabel: 'Log First Interaction',
      onAction: onLogInteraction,
    );
  }
}
