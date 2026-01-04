import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedAvatar extends StatefulWidget {
  final double size;
  final IconData icon;
  final List<Color> gradientColors;
  final bool showBadge;
  final bool enableFloating;

  const AnimatedAvatar({
    super.key,
    this.size = 120,
    this.icon = Icons.person,
    this.gradientColors = const [Color(0xFF667eea), Color(0xFF764ba2)],
    this.showBadge = true,
    this.enableFloating = true,
  });

  @override
  State<AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<AnimatedAvatar>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _rotateController;
  late AnimationController _glowController;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 10000),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    _glowAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    if (widget.enableFloating) {
      _floatController.repeat(reverse: true);
    }
    _rotateController.repeat();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _rotateController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatAnimation,
        _rotateAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Cercles d'aura rotatifs
              Transform.rotate(
                angle: _rotateAnimation.value,
                child: CustomPaint(
                  size: Size(widget.size + 60, widget.size + 60),
                  painter: _AuraPainter(
                    colors: widget.gradientColors,
                    glowIntensity: _glowAnimation.value,
                  ),
                ),
              ),

              // Avatar principal
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: widget.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradientColors[0]
                          .withValues(alpha: 0.5 * _glowAnimation.value),
                      blurRadius: 30 * _glowAnimation.value,
                      spreadRadius: 10 * _glowAnimation.value,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Effet de brillance
                    Positioned.fill(
                      child: ClipOval(
                        child: CustomPaint(
                          painter: _ShinePainter(),
                        ),
                      ),
                    ),
                    // Icône
                    Center(
                      child: Icon(
                        widget.icon,
                        size: widget.size * 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Badge vérifié
              if (widget.showBadge)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF43e97b)
                                    .withValues(alpha: 0.6),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: widget.size * 0.2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AuraPainter extends CustomPainter {
  final List<Color> colors;
  final double glowIntensity;

  _AuraPainter({required this.colors, required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Dessiner plusieurs cercles d'aura
    for (int i = 0; i < 3; i++) {
      final radius = (size.width / 2) * (0.7 - i * 0.15);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..shader = LinearGradient(
          colors: [
            colors[0].withValues(alpha: 0.3 / (i + 1) * glowIntensity),
            colors[1].withValues(alpha: 0.3 / (i + 1) * glowIntensity),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, paint);
    }

    // Dessiner des points lumineux sur le cercle
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final x = center.dx + (size.width / 2) * 0.7 * math.cos(angle);
      final y = center.dy + (size.width / 2) * 0.7 * math.sin(angle);

      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6 * glowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(Offset(x, y), 4, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_AuraPainter oldDelegate) =>
      glowIntensity != oldDelegate.glowIntensity;
}

class _ShinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
