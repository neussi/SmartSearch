import 'package:flutter/material.dart';
import 'dart:math' as math;

class LiquidProgress extends StatefulWidget {
  final double progress;
  final double size;
  final List<Color> liquidColors;

  const LiquidProgress({
    super.key,
    required this.progress,
    this.size = 100,
    this.liquidColors = const [Color(0xFF4facfe), Color(0xFF00f2fe)],
  });

  @override
  State<LiquidProgress> createState() => _LiquidProgressState();
}

class _LiquidProgressState extends State<LiquidProgress>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fillController;
  late Animation<double> _waveAnimation;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fillController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);

    _fillAnimation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _fillController,
      curve: Curves.easeOutCubic,
    ));

    _waveController.repeat();
    _fillController.forward();
  }

  @override
  void didUpdateWidget(LiquidProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _fillAnimation = Tween<double>(
        begin: _fillAnimation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _fillController,
        curve: Curves.easeOutCubic,
      ));
      _fillController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveAnimation, _fillAnimation]),
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Conteneur circulaire
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
              ),

              // Liquide animé
              ClipOval(
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _LiquidPainter(
                    progress: _fillAnimation.value,
                    wavePhase: _waveAnimation.value,
                    colors: widget.liquidColors,
                  ),
                ),
              ),

              // Texte de pourcentage
              Text(
                '${(_fillAnimation.value * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.size * 0.25,
                  fontWeight: FontWeight.bold,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LiquidPainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final List<Color> colors;

  _LiquidPainter({
    required this.progress,
    required this.wavePhase,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final waveHeight = size.height * (1 - progress);
    final waveAmplitude = size.height * 0.05;
    final waveLength = size.width;

    final path = Path();
    path.moveTo(0, size.height);

    // Première vague
    for (double x = 0; x <= size.width; x++) {
      final y = waveHeight +
          waveAmplitude *
              math.sin((x / waveLength * 2 * math.pi * 2) + wavePhase);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    // Gradient de liquide
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);

    // Deuxième vague (plus subtile)
    final path2 = Path();
    path2.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = waveHeight +
          waveAmplitude *
              0.7 *
              math.sin((x / waveLength * 2 * math.pi * 2) - wavePhase + math.pi / 4);
      path2.lineTo(x, y);
    }

    path2.lineTo(size.width, size.height);
    path2.close();

    final paint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors[0].withValues(alpha: 0.5),
          colors[1].withValues(alpha: 0.5),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path2, paint2);

    // Effet de brillance sur le liquide
    final shinePath = Path();
    shinePath.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = waveHeight +
          waveAmplitude *
              math.sin((x / waveLength * 2 * math.pi * 2) + wavePhase);
      shinePath.lineTo(x, y);
    }

    shinePath.lineTo(size.width, waveHeight - 30);
    shinePath.lineTo(0, waveHeight - 30);
    shinePath.close();

    final shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, waveHeight - 30, size.width, 30));

    canvas.drawPath(shinePath, shinePaint);
  }

  @override
  bool shouldRepaint(_LiquidPainter oldDelegate) =>
      progress != oldDelegate.progress || wavePhase != oldDelegate.wavePhase;
}
