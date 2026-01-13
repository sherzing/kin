import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/services/haptic_service.dart';

/// An animated celebration overlay that displays when the Daily Deck is cleared.
///
/// Shows animated confetti-like particles and a success message.
class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    super.key,
    this.onComplete,
  });

  /// Called when the celebration animation completes.
  final VoidCallback? onComplete;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _textController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final List<_ConfettiParticle> _particles = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();

    // Generate confetti particles
    for (int i = 0; i < 50; i++) {
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        startY: -0.1 - _random.nextDouble() * 0.3,
        endY: 1.1 + _random.nextDouble() * 0.2,
        size: 6 + _random.nextDouble() * 8,
        color: _confettiColors[_random.nextInt(_confettiColors.length)],
        delay: _random.nextDouble() * 0.3,
        rotationSpeed: _random.nextDouble() * 4 - 2,
      ));
    }

    // Confetti animation
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.5),
      ),
    );

    // Start animations
    _confettiController.forward();
    _textController.forward();

    // Haptic feedback
    HapticService.heavyImpact();

    // Notify when complete
    _confettiController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _textController.dispose();
    super.dispose();
  }

  static const List<Color> _confettiColors = [
    Color(0xFFFF6B6B), // Red
    Color(0xFF4ECDC4), // Teal
    Color(0xFFFFE66D), // Yellow
    Color(0xFF95E1D3), // Mint
    Color(0xFFDDA0DD), // Plum
    Color(0xFF87CEEB), // Sky Blue
    Color(0xFFFFA07A), // Light Salmon
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti particles
        AnimatedBuilder(
          animation: _confettiController,
          builder: (context, child) {
            return CustomPaint(
              painter: _ConfettiPainter(
                particles: _particles,
                progress: _confettiController.value,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Center celebration text
        Center(
          child: AnimatedBuilder(
            animation: _textController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withAlpha(51),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.celebration,
                    size: 64,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'All Done!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Great job staying connected!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.green.shade600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Data for a single confetti particle.
class _ConfettiParticle {
  _ConfettiParticle({
    required this.x,
    required this.startY,
    required this.endY,
    required this.size,
    required this.color,
    required this.delay,
    required this.rotationSpeed,
  });

  final double x;
  final double startY;
  final double endY;
  final double size;
  final Color color;
  final double delay;
  final double rotationSpeed;
}

/// Custom painter for confetti particles.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Apply delay
      final adjustedProgress = ((progress - particle.delay) / (1 - particle.delay))
          .clamp(0.0, 1.0);

      if (adjustedProgress <= 0) continue;

      // Calculate position with slight wave motion
      final x = particle.x * size.width +
          sin(adjustedProgress * pi * 3) * 30;
      final y = particle.startY +
          (particle.endY - particle.startY) * adjustedProgress;
      final actualY = y * size.height;

      // Fade out at the end
      final opacity = (1 - adjustedProgress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = particle.color.withAlpha((opacity * 255).toInt());

      // Draw rotating rectangle
      canvas.save();
      canvas.translate(x, actualY);
      canvas.rotate(adjustedProgress * particle.rotationSpeed * pi * 2);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
