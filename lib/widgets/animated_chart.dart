import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedChart extends StatefulWidget {
  final List<double> data;
  final List<String> labels;
  final List<Color> gradientColors;
  final double height;

  const AnimatedChart({
    super.key,
    required this.data,
    required this.labels,
    this.gradientColors = const [Color(0xFF4facfe), Color(0xFF00f2fe)],
    this.height = 200,
  });

  @override
  State<AnimatedChart> createState() => _AnimatedChartState();
}

class _AnimatedChartState extends State<AnimatedChart>
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
          size: Size(double.infinity, widget.height),
          painter: _ChartPainter(
            data: widget.data,
            labels: widget.labels,
            gradientColors: widget.gradientColors,
            progress: _animation.value,
          ),
        );
      },
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final List<Color> gradientColors;
  final double progress;

  _ChartPainter({
    required this.data,
    required this.labels,
    required this.gradientColors,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxValue = data.reduce(math.max);
    final barWidth = size.width / (data.length * 2);
    final spacing = barWidth;

    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i] / maxValue) * size.height * 0.8 * progress;
      final x = (i * (barWidth + spacing)) + spacing;
      final y = size.height - barHeight;

      // Dessiner l'ombre de la barre
      final shadowPaint = Paint()
        ..color = gradientColors[0].withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 4, y + 4, barWidth, barHeight),
          const Radius.circular(8),
        ),
        shadowPaint,
      );

      // Dessiner la barre avec gradient
      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(8),
        ),
        barPaint,
      );

      // Effet de brillance
      final highlightPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(x, y, barWidth / 2, barHeight));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth / 2, barHeight),
          const Radius.circular(8),
        ),
        highlightPaint,
      );

      // Dessiner le label
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, size.height - 20),
      );

      // Dessiner la valeur au-dessus de la barre
      final valuePainter = TextPainter(
        text: TextSpan(
          text: data[i].toInt().toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      valuePainter.layout();
      valuePainter.paint(
        canvas,
        Offset(x + (barWidth - valuePainter.width) / 2, y - 25),
      );
    }
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) => progress != oldDelegate.progress;
}
