import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingMenu extends StatefulWidget {
  final List<FloatingMenuItem> items;
  final Widget mainButton;
  final Color backgroundColor;

  const FloatingMenu({
    super.key,
    required this.items,
    required this.mainButton,
    this.backgroundColor = const Color(0xFF667eea),
  });

  @override
  State<FloatingMenu> createState() => _FloatingMenuState();
}

class _FloatingMenuState extends State<FloatingMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.875,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isExpanded)
          GestureDetector(
            onTap: _toggle,
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        ..._buildMenuItems(),
        _buildMainButton(),
      ],
    );
  }

  List<Widget> _buildMenuItems() {
    final items = <Widget>[];
    for (int i = 0; i < widget.items.length; i++) {
      items.add(_buildMenuItem(widget.items[i], i));
    }
    return items;
  }

  Widget _buildMenuItem(FloatingMenuItem item, int index) {
    final angle = (math.pi / 2) / (widget.items.length - 1) * index;
    final distance = 100.0;

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final offset = Offset(
          -math.cos(angle) * distance * _expandAnimation.value,
          -math.sin(angle) * distance * _expandAnimation.value,
        );

        return Positioned(
          right: 16 + offset.dx,
          bottom: 16 + offset.dy,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: ScaleTransition(
              scale: _expandAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'menu_item_$index',
                    mini: true,
                    onPressed: () {
                      _toggle();
                      item.onTap();
                    },
                    backgroundColor: item.color,
                    child: Icon(item.icon, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainButton() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 2 * math.pi,
            child: FloatingActionButton(
              heroTag: 'main_menu_button',
              onPressed: _toggle,
              backgroundColor: widget.backgroundColor,
              elevation: 8,
              child: widget.mainButton,
            ),
          );
        },
      ),
    );
  }
}

class FloatingMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  FloatingMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = const Color(0xFF667eea),
  });
}
