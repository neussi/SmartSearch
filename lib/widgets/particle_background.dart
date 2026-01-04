import 'package:flutter/material.dart';
import 'dart:math' as math;

class ParticleBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final List<Color> particleColors;

  const ParticleBackground({
    super.key,
    required this.child,
    this.particleCount = 30,
    this.particleColors = const [
      Colors.white,
      Color(0xFF667eea),
      Color(0xFF764ba2),
    ],
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (index) => Particle(
        x: math.Random().nextDouble(),
        y: math.Random().nextDouble(),
        size: math.Random().nextDouble() * 4 + 2,
        speedX: (math.Random().nextDouble() - 0.5) * 0.002,
        speedY: (math.Random().nextDouble() - 0.5) * 0.002,
        color: widget.particleColors[
            math.Random().nextInt(widget.particleColors.length)],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            _updateParticles();
            return CustomPaint(
              painter: ParticlePainter(_particles),
              child: Container(),
            );
          },
        ),
        widget.child,
      ],
    );
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.x += particle.speedX;
      particle.y += particle.speedY;

      if (particle.x < 0 || particle.x > 1) particle.speedX *= -1;
      if (particle.y < 0 || particle.y > 1) particle.speedY *= -1;

      particle.x = particle.x.clamp(0.0, 1.0);
      particle.y = particle.y.clamp(0.0, 1.0);
    }
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speedX;
  double speedY;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.color,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
