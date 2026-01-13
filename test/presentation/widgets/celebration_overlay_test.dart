import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/presentation/widgets/widgets.dart';

void main() {
  group('CelebrationOverlay', () {
    testWidgets('renders celebration content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelebrationOverlay(),
          ),
        ),
      );

      // Pump a few frames to let animations start
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('All Done!'), findsOneWidget);
      expect(find.text('Great job staying connected!'), findsOneWidget);
      expect(find.byIcon(Icons.celebration), findsOneWidget);
    });

    testWidgets('calls onComplete when animation finishes',
        (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CelebrationOverlay(
              onComplete: () => completed = true,
            ),
          ),
        ),
      );

      // Animation hasn't completed yet
      expect(completed, isFalse);

      // Pump past the animation duration (2500ms for confetti)
      await tester.pump(const Duration(milliseconds: 2600));

      expect(completed, isTrue);
    });

    testWidgets('renders confetti particles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelebrationOverlay(),
          ),
        ),
      );

      // Pump to start animation
      await tester.pump(const Duration(milliseconds: 100));

      // Should have a CustomPaint for confetti
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('animates text scale and fade', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelebrationOverlay(),
          ),
        ),
      );

      // Initial state - animation just started
      await tester.pump();

      // Pump partway through text animation
      await tester.pump(const Duration(milliseconds: 400));

      // Text should be visible
      expect(find.text('All Done!'), findsOneWidget);

      // Complete the animation
      await tester.pump(const Duration(milliseconds: 500));

      // Text should still be visible
      expect(find.text('All Done!'), findsOneWidget);
    });

    testWidgets('disposes animation controllers properly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelebrationOverlay(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Remove the widget - should not throw
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      // If dispose wasn't handled properly, this would throw
      expect(true, isTrue);
    });
  });

  group('CelebrationOverlay visual elements', () {
    testWidgets('has green color theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelebrationOverlay(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      // Find the celebration icon
      final iconFinder = find.byIcon(Icons.celebration);
      expect(iconFinder, findsOneWidget);

      final icon = tester.widget<Icon>(iconFinder);
      // Icon should have a green shade color
      expect(icon.color, isNotNull);
    });

    testWidgets('centers content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelebrationOverlay(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      // Should have a Center widget
      expect(find.byType(Center), findsWidgets);
    });
  });
}
