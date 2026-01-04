import 'package:flutter/material.dart';
import 'dart:math' as math;

class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  final bool enableShadow;

  const TiltCard({
    super.key,
    required this.child,
    this.maxTilt = 0.05,
    this.enableShadow = true,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _tilt = Offset.zero;
  Offset _lightPosition = const Offset(0.5, 0.5);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerEvent details, Size size) {
    setState(() {
      final dx = (details.localPosition.dx / size.width - 0.5);
      final dy = (details.localPosition.dy / size.height - 0.5);
      _tilt = Offset(dx, dy);
      _lightPosition = Offset(
        details.localPosition.dx / size.width,
        details.localPosition.dy / size.height,
      );
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() {
      _tilt = Offset.zero;
      _lightPosition = const Offset(0.5, 0.5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (event) => _onPointerMove(event, constraints.biggest),
          onExit: (_) => _onPointerUp(PointerUpEvent(position: Offset.zero)),
          child: Listener(
            onPointerMove: (event) => _onPointerMove(event, constraints.biggest),
            onPointerUp: _onPointerUp,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(-_tilt.dy * widget.maxTilt)
                ..rotateY(_tilt.dx * widget.maxTilt),
              child: Stack(
                children: [
                  widget.child,
                  // Effet de lumière qui suit le curseur
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CustomPaint(
                        painter: _LightPainter(
                          position: _lightPosition,
                          intensity: _tilt.distance,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LightPainter extends CustomPainter {
  final Offset position;
  final double intensity;

  _LightPainter({required this.position, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          position.dx * 2 - 1,
          position.dy * 2 - 1,
        ),
        radius: 0.8,
        colors: [
          Colors.white.withOpacity(0.3 * intensity),
          Colors.white.withOpacity(0.1 * intensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_LightPainter oldDelegate) =>
      position != oldDelegate.position || intensity != oldDelegate.intensity;
}
