import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/core/services/haptic_service.dart';

void main() {
  // Ensure bindings are initialized for haptic feedback
  TestWidgetsFlutterBinding.ensureInitialized();

  // Note: Actual haptic feedback cannot be tested in unit tests.
  // These tests verify the methods exist and can be called without throwing.

  group('HapticService', () {
    test('mediumImpact can be called', () {
      // Should not throw
      expect(() => HapticService.mediumImpact(), returnsNormally);
    });

    test('selectionClick can be called', () {
      // Should not throw
      expect(() => HapticService.selectionClick(), returnsNormally);
    });

    test('lightImpact can be called', () {
      // Should not throw
      expect(() => HapticService.lightImpact(), returnsNormally);
    });

    test('heavyImpact can be called', () {
      // Should not throw
      expect(() => HapticService.heavyImpact(), returnsNormally);
    });
  });
}
