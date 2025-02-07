import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final void Function()? onPressed;
  final bool isEnabled;
  final bool isPrimary;
  final bool showShine;

  const GameActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isEnabled = true,
    this.isPrimary = true,
    this.showShine = true,
  });

  @override
  State<GameActionButton> createState() => _GameActionButtonState();
}

class _GameActionButtonState extends State<GameActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shineAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _shineAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isPrimary
                      ? [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ]
                      : [
                          Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.1),
                          Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.2),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isPrimary
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface)
                        .withOpacity(_isPressed ? 0.2 : 0.4),
                    blurRadius: _isPressed ? 8 : 16,
                    offset: Offset(0, _isPressed ? 2 : 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.isPrimary
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.isPrimary
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (widget.showShine)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Transform.rotate(
                            angle: -0.8,
                            child: Transform.translate(
                              offset: Offset(
                                _shineAnimation.value * 100,
                                0,
                              ),
                              child: Container(
                                width: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0),
                                      Colors.white.withOpacity(0.2),
                                      Colors.white.withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
