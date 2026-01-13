import 'package:flutter/services.dart';

/// Service for providing haptic feedback throughout the app.
///
/// Provides consistent haptic feedback patterns for different actions:
/// - [mediumImpact] for successful completions (interaction logged, task done)
/// - [selectionClick] for UI selections (date pickers, toggles, carousel snaps)
/// - [lightImpact] for subtle feedback (button taps)
abstract final class HapticService {
  /// Medium impact feedback for successful completions.
  ///
  /// Use when:
  /// - Interaction is successfully logged
  /// - Contact is marked as contacted
  /// - Task completion
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Selection click feedback for UI interactions.
  ///
  /// Use when:
  /// - Date/time is selected in pickers
  /// - Toggle or switch changes
  /// - Carousel snaps to a new position
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Light impact feedback for subtle interactions.
  ///
  /// Use when:
  /// - Button taps that need acknowledgment
  /// - Minor UI state changes
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Heavy impact feedback for significant actions.
  ///
  /// Use sparingly for:
  /// - Destructive actions confirmed
  /// - Major milestones (all tasks complete)
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }
}
