import 'package:flutter/material.dart';
import 'package:phonix_scanner/models/settings_model.dart';
import 'package:provider/provider.dart';

class Logo extends StatefulWidget {
  const Logo({
    super.key,
    required this.size,
    this.isAnimated = false,
    this.action,
  });

  final double size;
  final bool isAnimated;
  final VoidCallback? action;

  @override
  State<Logo> createState() => _LogoState();
}

class _LogoState extends State<Logo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );
    _offsetAnim = Tween<double>(
      begin: -4.0,
      end: 4.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isAnimated) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant Logo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimated && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isAnimated && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final logoBytes = SettingsModel.decodeImageBytes(
      settings.customLogoImageBase64,
    );

    return AnimatedBuilder(
      animation: _offsetAnim,
      builder: (context, _) {
        final dy = widget.isAnimated ? _offsetAnim.value : 0.0;
        Widget content = Transform.translate(
          offset: Offset(0, dy),
          child: logoBytes == null
              ? Image.asset(
                  'assets/images/phoenix.png',
                  color: settings.fontColor,
                  width: widget.size,
                  height: widget.size,
                )
              : Image.memory(
                  logoBytes,
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.contain,
                ),
        );
        if (widget.action != null) {
          content = GestureDetector(onTap: widget.action, child: content);
        }
        return content;
      },
    );
  }
}
