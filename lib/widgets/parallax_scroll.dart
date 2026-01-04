import 'package:flutter/material.dart';

class ParallaxScroll extends StatelessWidget {
  final Widget background;
  final Widget foreground;
  final double backgroundSpeed;
  final double foregroundSpeed;

  const ParallaxScroll({
    super.key,
    required this.background,
    required this.foreground,
    this.backgroundSpeed = 0.3,
    this.foregroundSpeed = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) => true,
          child: Stack(
            children: [
              _ParallaxLayer(
                child: background,
                speed: backgroundSpeed,
              ),
              _ParallaxLayer(
                child: foreground,
                speed: foregroundSpeed,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ParallaxLayer extends StatefulWidget {
  final Widget child;
  final double speed;

  const _ParallaxLayer({
    required this.child,
    required this.speed,
  });

  @override
  State<_ParallaxLayer> createState() => _ParallaxLayerState();
}

class _ParallaxLayerState extends State<_ParallaxLayer> {
  double _offset = 0;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          setState(() {
            _offset = notification.metrics.pixels * widget.speed;
          });
        }
        return false;
      },
      child: Transform.translate(
        offset: Offset(0, -_offset),
        child: widget.child,
      ),
    );
  }
}

class ParallaxImage extends StatelessWidget {
  final ImageProvider imageProvider;
  final double offset;
  final BoxFit fit;

  const ParallaxImage({
    super.key,
    required this.imageProvider,
    required this.offset,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offset * 0.5),
      child: Image(
        image: imageProvider,
        fit: fit,
      ),
    );
  }
}

class HorizontalParallax extends StatelessWidget {
  final List<ParallaxItem> items;
  final double height;

  const HorizontalParallax({
    super.key,
    required this.items,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _HorizontalParallaxItem(
            item: items[index],
            index: index,
          );
        },
      ),
    );
  }
}

class _HorizontalParallaxItem extends StatefulWidget {
  final ParallaxItem item;
  final int index;

  const _HorizontalParallaxItem({
    required this.item,
    required this.index,
  });

  @override
  State<_HorizontalParallaxItem> createState() =>
      _HorizontalParallaxItemState();
}

class _HorizontalParallaxItemState extends State<_HorizontalParallaxItem> {
  double _offset = 0;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          setState(() {
            _offset = notification.metrics.pixels * 0.1;
          });
        }
        return false;
      },
      child: Transform.translate(
        offset: Offset(-_offset, 0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: widget.item.child,
        ),
      ),
    );
  }
}

class ParallaxItem {
  final Widget child;
  final double speed;

  ParallaxItem({
    required this.child,
    this.speed = 1.0,
  });
}

class AnimatedParallaxBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;

  const AnimatedParallaxBackground({
    super.key,
    required this.child,
    required this.colors,
  });

  @override
  State<AnimatedParallaxBackground> createState() =>
      _AnimatedParallaxBackgroundState();
}

class _AnimatedParallaxBackgroundState
    extends State<AnimatedParallaxBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          setState(() {
            _scrollOffset = notification.metrics.pixels;
          });
        }
        return false;
      },
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.colors,
                    stops: [
                      0.0 + _controller.value * 0.2,
                      0.3 + _controller.value * 0.2,
                      0.6 + _controller.value * 0.2,
                      1.0,
                    ].map((e) => e % 1.0).toList(),
                  ),
                ),
              );
            },
          ),
          Transform.translate(
            offset: Offset(0, -_scrollOffset * 0.3),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
