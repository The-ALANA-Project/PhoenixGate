import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class BackgroundAnimation extends StatefulWidget {
  const BackgroundAnimation({
    super.key,
    required this.child,
    required this.baseColor,
    required this.glowColor,
    this.particleCount = 12,
  });

  final Widget child;
  final Color baseColor;
  final Color glowColor;
  final int particleCount;

  @override
  State<BackgroundAnimation> createState() => _BackgroundAnimationState();
}

class _BackgroundAnimationState extends State<BackgroundAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 36),
    )..repeat();

    _loadShader();
  }

  Future<void> _loadShader() async {
    final program = await ui.FragmentProgram.fromAsset(
      'shaders/background_noise.frag',
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _shader = program.fragmentShader();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shader = _shader;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          if (shader == null) {
            return DecoratedBox(
              decoration: BoxDecoration(color: widget.baseColor),
              child: child,
            );
          }

          return CustomPaint(
            painter: _ShaderBackgroundPainter(
              t: _controller.value,
              baseColor: widget.baseColor,
              glowColor: widget.glowColor,
              shader: shader,
              particleCount: widget.particleCount,
            ),
            child: child,
          );
        },
      ),
    );
  }
}

class _ShaderBackgroundPainter extends CustomPainter {
  _ShaderBackgroundPainter({
    required this.t,
    required this.baseColor,
    required this.glowColor,
    required this.shader,
    required this.particleCount,
  });

  final double t;
  final Color baseColor;
  final Color glowColor;
  final ui.FragmentShader shader;
  final int particleCount;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final time = t * 36.0;

    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, baseColor.red / 255.0)
      ..setFloat(4, baseColor.green / 255.0)
      ..setFloat(5, baseColor.blue / 255.0)
      ..setFloat(6, baseColor.alpha / 255.0)
      ..setFloat(7, glowColor.red / 255.0)
      ..setFloat(8, glowColor.green / 255.0)
      ..setFloat(9, glowColor.blue / 255.0)
      ..setFloat(10, glowColor.alpha / 255.0);

    canvas.drawRect(bounds, Paint()..shader = shader);
    _paintParticles(canvas, size, time);
  }

  void _paintParticles(Canvas canvas, Size size, double time) {
    if (particleCount <= 0 || size.isEmpty) {
      return;
    }

    final particleColor = Color.lerp(const Color(0xFFFFFFFF), glowColor, 0.2)!;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.plus;

    for (var i = 0; i < particleCount; i++) {
      final seed = i + 1;
      final speedY = 14.0 + _hash01(seed * 17) * 26.0;
      final speedX = 4.0 + _hash01(seed * 23) * 16.0;
      final baseX = _hash01(seed * 31) * size.width;
      final baseY = _hash01(seed * 47) * size.height;
      final phase = _hash01(seed * 71) * math.pi * 2.0;
      final radius = 0.7 + _hash01(seed * 97) * 1.5;
      final twinkle =
          0.35 +
          0.65 *
              (0.5 +
                  0.5 * math.sin(time * (0.9 + _hash01(seed * 131)) + phase));

      final x =
          (baseX + time * speedX + math.sin(time * 0.9 + phase) * 14.0) %
          size.width;
      final y = (baseY - time * speedY) % size.height;
      final wrappedY = y < 0 ? y + size.height : y;

      paint.color = particleColor.withOpacity(twinkle.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, wrappedY), radius, paint);
    }
  }

  double _hash01(int value) {
    final x = math.sin(value * 12.9898) * 43758.5453;
    return x - x.floorToDouble();
  }

  @override
  bool shouldRepaint(covariant _ShaderBackgroundPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.shader != shader ||
        oldDelegate.particleCount != particleCount;
  }
}
