import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/core/theme/app_colors.dart';
import 'package:kin/presentation/widgets/health_ring.dart';

void main() {
  group('HealthRingFromValues', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HealthRingFromValues(
              lastContactedAt: null,
              cadenceDays: 30,
              child: CircleAvatar(child: Text('AB')),
            ),
          ),
        ),
      );

      expect(find.text('AB'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('applies correct size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HealthRingFromValues(
              lastContactedAt: null,
              cadenceDays: 30,
              size: 64,
              child: CircleAvatar(),
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 64);
      expect(sizedBox.height, 64);
    });

    testWidgets('uses CustomPaint for ring', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HealthRingFromValues(
              lastContactedAt: null,
              cadenceDays: 30,
              child: CircleAvatar(),
            ),
          ),
        ),
      );

      // CustomPaint is used for the health ring rendering
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('calculateHealthPercentage', () {
    test('returns infinity when lastContactedAt is null', () {
      final result = calculateHealthPercentage(
        lastContactedAt: null,
        cadenceDays: 30,
      );

      expect(result, double.infinity);
    });

    test('returns infinity when cadenceDays is 0', () {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final result = calculateHealthPercentage(
        lastContactedAt: now,
        cadenceDays: 0,
      );

      expect(result, double.infinity);
    });

    test('returns 0 when just contacted', () {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final result = calculateHealthPercentage(
        lastContactedAt: now,
        cadenceDays: 30,
      );

      expect(result, closeTo(0.0, 0.01));
    });

    test('returns 0.5 when half cadence elapsed', () {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final fifteenDaysAgo = now - (15 * 86400);
      final result = calculateHealthPercentage(
        lastContactedAt: fifteenDaysAgo,
        cadenceDays: 30,
      );

      expect(result, closeTo(0.5, 0.01));
    });

    test('returns 1.0 when full cadence elapsed', () {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final thirtyDaysAgo = now - (30 * 86400);
      final result = calculateHealthPercentage(
        lastContactedAt: thirtyDaysAgo,
        cadenceDays: 30,
      );

      expect(result, closeTo(1.0, 0.01));
    });

    test('returns > 1.0 when overdue', () {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final fortyFiveDaysAgo = now - (45 * 86400);
      final result = calculateHealthPercentage(
        lastContactedAt: fortyFiveDaysAgo,
        cadenceDays: 30,
      );

      expect(result, closeTo(1.5, 0.01));
    });
  });

  group('getHealthColor', () {
    test('returns green for 0% to 50%', () {
      expect(getHealthColor(0.0), AppColors.healthGreen);
      expect(getHealthColor(0.25), AppColors.healthGreen);
      expect(getHealthColor(0.5), AppColors.healthGreen);
    });

    test('returns yellow for 51% to 100%', () {
      expect(getHealthColor(0.51), AppColors.healthYellow);
      expect(getHealthColor(0.75), AppColors.healthYellow);
      expect(getHealthColor(1.0), AppColors.healthYellow);
    });

    test('returns red for over 100%', () {
      expect(getHealthColor(1.01), AppColors.healthRed);
      expect(getHealthColor(1.5), AppColors.healthRed);
      expect(getHealthColor(2.0), AppColors.healthRed);
    });
  });
}
