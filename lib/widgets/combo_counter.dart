import 'package:flutter/material.dart';

class ComboCounter extends StatefulWidget {
  final int combo;
  final int multiplier;
  final bool isActive;

  const ComboCounter({
    super.key,
    required this.combo,
    required this.multiplier,
    this.isActive = true,
  });

  @override
  State<ComboCounter> createState() => _ComboCounterState();
}

class _ComboCounterState extends State<ComboCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.5),
        weight: 25.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 1.0),
        weight: 75.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 25.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 75.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ComboCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.combo != oldWidget.combo ||
        widget.multiplier != oldWidget.multiplier) {
      _controller.forward(from: 0);
    }
  }

  Color _getComboColor() {
    if (widget.combo >= 10) return Colors.red;
    if (widget.combo >= 7) return Colors.orange;
    if (widget.combo >= 5) return Colors.yellow;
    if (widget.combo >= 3) return Colors.green;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive || widget.combo <= 1) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _getComboColor().withOpacity(_glowAnimation.value * 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Row(
                  children: [
                    Icon(
                      Icons.flash_on,
                      color: _getComboColor(),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.combo}',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: _getComboColor(),
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),
              if (widget.multiplier > 1) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getComboColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'x${widget.multiplier}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _getComboColor(),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
