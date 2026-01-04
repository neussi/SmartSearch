import 'package:flutter/material.dart';
import 'dart:math' as math;

class RadialStats extends StatefulWidget {
  final List<RadialStatData> stats;
  final double size;

  const RadialStats({
    super.key,
    required this.stats,
    this.size = 200,
  });

  @override
  State<RadialStats> createState() => _RadialStatsState();
}

class _RadialStatsState extends State<RadialStats>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _RadialStatsPainter(
            stats: widget.stats,
            progress: _animation.value,
          ),
        );
      },
    );
  }
}

class RadialStatData {
  final String label;
  final double value;
  final double maxValue;
  final Color color;
  final IconData icon;

  RadialStatData({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.icon,
  });

  double get progress => value / maxValue;
}

class _RadialStatsPainter extends CustomPainter {
  final List<RadialStatData> stats;
  final double progress;

  _RadialStatsPainter({
    required this.stats,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 40;
    final ringWidth = 15.0;
    final spacing = 5.0;

    for (int i = 0; i < stats.length; i++) {
      final stat = stats[i];
      final radius = maxRadius - (i * (ringWidth + spacing));
      final currentProgress = stat.progress * progress;

      // Cercle de fond
      final bgPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius, bgPaint);

      // Arc de progression
      final progressPaint = Paint()
        ..color = stat.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * currentProgress,
        false,
        progressPaint,
      );

      // Point lumineux à la fin de l'arc
      if (currentProgress > 0) {
        final endAngle = -math.pi / 2 + (2 * math.pi * currentProgress);
        final endX = center.dx + radius * math.cos(endAngle);
        final endY = center.dy + radius * math.sin(endAngle);

        final glowPaint = Paint()
          ..color = stat.color.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

        canvas.drawCircle(Offset(endX, endY), 8, glowPaint);

        final dotPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(endX, endY), 5, dotPaint);
      }

      // Label et valeur
      final angle = -math.pi / 2 + math.pi / 4 + (i * math.pi / 3);
      final labelRadius = radius + 25;
      final labelX = center.dx + labelRadius * math.cos(angle);
      final labelY = center.dy + labelRadius * math.sin(angle);

      // Dessiner le label
      final textPainter = TextPainter(
        text: TextSpan(
          text: stat.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelX - textPainter.width / 2, labelY - 20),
      );

      // Dessiner la valeur
      final valuePainter = TextPainter(
        text: TextSpan(
          text: '${(stat.progress * 100).toInt()}%',
          style: TextStyle(
            color: stat.color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      valuePainter.layout();
      valuePainter.paint(
        canvas,
        Offset(labelX - valuePainter.width / 2, labelY - 5),
      );
    }

    // Dessiner le centre avec icône
    final centerPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF667eea),
          Color(0xFF764ba2),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 30));

    canvas.drawCircle(center, 30, centerPaint);

    // Effet de brillance au centre
    final shinePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.5),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 30));

    canvas.drawCircle(center, 30, shinePaint);
  }

  @override
  bool shouldRepaint(_RadialStatsPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
