import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/database/database.dart';

/// A circular progress ring that displays relationship health status.
///
/// The ring shows how much of the contact cadence has elapsed:
/// - 0-50% elapsed: Green ring
/// - 50-100% elapsed: Yellow ring
/// - 100%+ elapsed (overdue): Full red ring
///
/// The ring fills clockwise from the top as time passes since last contact.
class HealthRing extends StatelessWidget {
  const HealthRing({
    super.key,
    required this.child,
    required this.contact,
    this.size = 48.0,
    this.strokeWidth = 3.0,
    this.backgroundColor,
  });

  /// The widget to display inside the ring (typically an avatar).
  final Widget child;

  /// The contact whose health status to display.
  final Contact contact;

  /// The diameter of the ring.
  final double size;

  /// The width of the ring stroke.
  final double strokeWidth;

  /// Optional background color for the unfilled portion of the ring.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final healthData = _calculateHealth();

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HealthRingPainter(
          progress: healthData.progress,
          color: healthData.color,
          strokeWidth: strokeWidth,
          backgroundColor: backgroundColor ?? Colors.grey.shade200,
        ),
        child: Padding(
          padding: EdgeInsets.all(strokeWidth + 2),
          child: child,
        ),
      ),
    );
  }

  _HealthData _calculateHealth() {
    if (contact.lastContactedAt == null) {
      // Never contacted - show full red ring
      return _HealthData(progress: 1.0, color: AppColors.healthRed);
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final lastContact = contact.lastContactedAt!;
    final cadenceSeconds = contact.cadenceDays * 86400;

    if (cadenceSeconds == 0) {
      return _HealthData(progress: 1.0, color: AppColors.healthRed);
    }

    final elapsed = now - lastContact;
    final percentage = elapsed / cadenceSeconds;

    if (percentage <= 0.5) {
      return _HealthData(progress: percentage, color: AppColors.healthGreen);
    } else if (percentage <= 1.0) {
      return _HealthData(progress: percentage, color: AppColors.healthYellow);
    } else {
      // Overdue - show full ring in red
      return _HealthData(progress: 1.0, color: AppColors.healthRed);
    }
  }
}

/// Simplified HealthRing that calculates health from raw values.
///
/// Use this when you don't have a full Contact object.
class HealthRingFromValues extends StatelessWidget {
  const HealthRingFromValues({
    super.key,
    required this.child,
    this.lastContactedAt,
    required this.cadenceDays,
    this.size = 48.0,
    this.strokeWidth = 3.0,
    this.backgroundColor,
  });

  final Widget child;
  final int? lastContactedAt;
  final int cadenceDays;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final healthData = _calculateHealth();

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HealthRingPainter(
          progress: healthData.progress,
          color: healthData.color,
          strokeWidth: strokeWidth,
          backgroundColor: backgroundColor ?? Colors.grey.shade200,
        ),
        child: Padding(
          padding: EdgeInsets.all(strokeWidth + 2),
          child: child,
        ),
      ),
    );
  }

  _HealthData _calculateHealth() {
    if (lastContactedAt == null) {
      return _HealthData(progress: 1.0, color: AppColors.healthRed);
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final cadenceSeconds = cadenceDays * 86400;

    if (cadenceSeconds == 0) {
      return _HealthData(progress: 1.0, color: AppColors.healthRed);
    }

    final elapsed = now - lastContactedAt!;
    final percentage = elapsed / cadenceSeconds;

    if (percentage <= 0.5) {
      return _HealthData(progress: percentage, color: AppColors.healthGreen);
    } else if (percentage <= 1.0) {
      return _HealthData(progress: percentage, color: AppColors.healthYellow);
    } else {
      return _HealthData(progress: 1.0, color: AppColors.healthRed);
    }
  }
}

/// Data class for health calculation results.
class _HealthData {
  const _HealthData({required this.progress, required this.color});

  final double progress;
  final Color color;
}

/// Custom painter for the health ring arc.
class _HealthRingPainter extends CustomPainter {
  _HealthRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  final double progress;
  final Color color;
  final double strokeWidth;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background ring
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      // Start from the top (-90 degrees = -pi/2)
      const startAngle = -math.pi / 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_HealthRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

/// Utility function to calculate health percentage for a contact.
///
/// Returns a value between 0.0 and 1.0+ where:
/// - 0.0 = just contacted
/// - 1.0 = due date reached
/// - >1.0 = overdue
double calculateHealthPercentage({
  int? lastContactedAt,
  required int cadenceDays,
}) {
  if (lastContactedAt == null) {
    return double.infinity; // Never contacted
  }

  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final cadenceSeconds = cadenceDays * 86400;

  if (cadenceSeconds == 0) {
    return double.infinity;
  }

  final elapsed = now - lastContactedAt;
  return elapsed / cadenceSeconds;
}

/// Returns the appropriate health color for a given percentage.
Color getHealthColor(double percentage) {
  if (percentage <= 0.5) {
    return AppColors.healthGreen;
  } else if (percentage <= 1.0) {
    return AppColors.healthYellow;
  } else {
    return AppColors.healthRed;
  }
}
