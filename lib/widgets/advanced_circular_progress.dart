import 'package:flutter/material.dart';
import 'dart:math' as math;

class AdvancedCircularProgress extends StatefulWidget {
  final double progress;
  final String label;
  final String? sublabel;
  final List<Color> gradientColors;
  final double size;
  final bool showPulse;

  const AdvancedCircularProgress({
    super.key,
    required this.progress,
    required this.label,
    this.sublabel,
    this.gradientColors = const [Color(0xFF667eea), Color(0xFF764ba2)],
    this.size = 120,
    this.showPulse = true,
  });

  @override
  State<AdvancedCircularProgress> createState() =>
      _AdvancedCircularProgressState();
}

class _AdvancedCircularProgressState extends State<AdvancedCircularProgress>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _progressController.forward();

    if (widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AdvancedCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Effet de halo pulsant
            if (widget.showPulse)
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: widget.size + 20,
                  height: widget.size + 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.gradientColors[0].withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),

            // Cercle de progression
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _CircularProgressPainter(
                  progress: _progressAnimation.value,
                  gradientColors: widget.gradientColors,
                ),
              ),
            ),

            // Labels au centre
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(_progressAnimation.value * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.size * 0.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.size * 0.12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.sublabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.sublabel!,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: widget.size * 0.1,
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final List<Color> gradientColors;

  _CircularProgressPainter({
    required this.progress,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Cercle de fond
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 6, bgPaint);

    // Cercle de progression avec gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      colors: gradientColors,
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + (2 * math.pi * progress),
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Points lumineux aux extrémités
    if (progress > 0) {
      final endAngle = -math.pi / 2 + (2 * math.pi * progress);
      final endPoint = Offset(
        center.dx + (radius - 6) * math.cos(endAngle),
        center.dy + (radius - 6) * math.sin(endAngle),
      );

      final glowPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(endPoint, 8, glowPaint);

      final dotPaint = Paint()
        ..color = gradientColors.last
        ..style = PaintingStyle.fill;

      canvas.drawCircle(endPoint, 6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
