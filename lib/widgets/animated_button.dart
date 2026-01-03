import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final List<Color>? gradientColors;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.gradientColors,
    this.borderRadius = 16,
    this.padding,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.gradientColors ??
        [
          const Color(0xFF667eea),
          const Color(0xFF764ba2),
        ];

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.onPressed == null
                  ? [Colors.grey.shade400, Colors.grey.shade500]
                  : gradientColors,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? gradientColors.first.withOpacity(0.3)
                    : gradientColors.first.withOpacity(0.5),
                blurRadius: _isPressed ? 10 : 20,
                offset: _isPressed ? const Offset(0, 4) : const Offset(0, 8),
              ),
            ],
          ),
          child: widget.isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
