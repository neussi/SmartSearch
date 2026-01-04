import 'package:flutter/material.dart';
import 'dart:math' as math;

class ConfettiAnimation extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback? onComplete;

  const ConfettiAnimation({
    super.key,
    required this.isPlaying,
    this.onComplete,
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Confetti> _confettiList = [];
  final random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
        _confettiList.clear();
      }
    });

    _generateConfetti();
  }

  void _generateConfetti() {
    _confettiList.clear();
    for (int i = 0; i < 100; i++) {
      _confettiList.add(Confetti(
        color: Color.fromRGBO(
          random.nextInt(255),
          random.nextInt(255),
          random.nextInt(255),
          1,
        ),
        angle: random.nextDouble() * 2 * math.pi,
        velocity: 200 + random.nextDouble() * 200,
        rotationSpeed: random.nextDouble() * 10 - 5,
        size: 5 + random.nextDouble() * 10,
      ));
    }
  }

  @override
  void didUpdateWidget(ConfettiAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _generateConfetti();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(
            confettiList: _confettiList,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class Confetti {
  final Color color;
  final double angle;
  final double velocity;
  final double rotationSpeed;
  final double size;

  Confetti({
    required this.color,
    required this.angle,
    required this.velocity,
    required this.rotationSpeed,
    required this.size,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<Confetti> confettiList;
  final double progress;

  _ConfettiPainter({required this.confettiList, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (var confetti in confettiList) {
      final distance = confetti.velocity * progress;
      final x = centerX + math.cos(confetti.angle) * distance;
      final y = centerY +
          math.sin(confetti.angle) * distance +
          (progress * progress * 500); // Effet de gravité

      final rotation = confetti.rotationSpeed * progress * 2 * math.pi;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final paint = Paint()
        ..color = confetti.color.withOpacity(1 - progress * 0.5)
        ..style = PaintingStyle.fill;

      // Dessiner un rectangle arrondi pour le confetti
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: confetti.size,
          height: confetti.size * 2,
        ),
        Radius.circular(confetti.size / 4),
      );

      canvas.drawRRect(rect, paint);

      // Ajouter un effet de brillance
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity((1 - progress) * 0.5)
        ..style = PaintingStyle.fill;

      final highlightRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(-confetti.size / 4, 0),
          width: confetti.size / 3,
          height: confetti.size * 2,
        ),
        Radius.circular(confetti.size / 4),
      );

      canvas.drawRRect(highlightRect, highlightPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
