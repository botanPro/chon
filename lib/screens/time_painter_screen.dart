import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TimePainterScreen extends StatefulWidget {
  const TimePainterScreen({super.key});

  @override
  State<TimePainterScreen> createState() => _TimePainterScreenState();
}

class _TimePainterScreenState extends State<TimePainterScreen>
    with TickerProviderStateMixin {
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  final List<PaintPoint> _points = [];
  final List<TimingCircle> _timingCircles = [];
  int _score = 0;
  int _combo = 0;
  int _perfectHits = 0;
  Timer? _gameTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String? _currentFeedback;
  bool _isGameActive = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _score = 0;
      _combo = 0;
      _perfectHits = 0;
      _points.clear();
      _timingCircles.clear();
    });

    _gameTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!_isGameActive) {
        timer.cancel();
        return;
      }

      setState(() {
        _timingCircles.add(TimingCircle(
          position: Offset(
            50 +
                Random().nextDouble() *
                    (MediaQuery.of(context).size.width - 100),
            50 +
                Random().nextDouble() *
                    (MediaQuery.of(context).size.height - 200),
          ),
          color: _colors[Random().nextInt(_colors.length)],
          size: 60.0,
          shrinkDuration: const Duration(milliseconds: 1500),
        ));
      });

      if (_timingCircles.length > 20) {
        _endGame();
      }
    });
  }

  void _onTapDown(TapDownDetails details) {
    if (!_isGameActive) return;

    final position = details.localPosition;
    TimingCircle? hitCircle;
    double? bestDistance;

    for (final circle in _timingCircles) {
      final distance = (circle.position - position).distance;
      final ratio = circle.currentSize / circle.size;

      if (distance < circle.size / 2) {
        if (bestDistance == null || distance < bestDistance) {
          bestDistance = distance;
          hitCircle = circle;
        }
      }
    }

    if (hitCircle != null) {
      final ratio = hitCircle.currentSize / hitCircle.size;
      _handleHit(position, hitCircle, ratio);
    }
  }

  void _handleHit(Offset position, TimingCircle circle, double ratio) {
    int points = 0;
    String feedback = '';

    if (ratio > 0.9) {
      points = 100;
      feedback = 'Perfect! ⭐️';
      _perfectHits++;
      _combo++;
    } else if (ratio > 0.7) {
      points = 50;
      feedback = 'Great! ✨';
      _combo++;
    } else if (ratio > 0.5) {
      points = 25;
      feedback = 'Good! 👍';
      _combo = 0;
    } else {
      points = 10;
      feedback = 'OK 👌';
      _combo = 0;
    }

    points *= (1 + _combo ~/ 5);

    setState(() {
      _score += points;
      _currentFeedback = feedback;
      _points.add(PaintPoint(
        position: position,
        color: circle.color,
        size: (1.1 - ratio) * 30,
      ));
      _timingCircles.remove(circle);
    });

    _pulseController.forward().then((_) => _pulseController.reverse());
  }

  void _endGame() {
    setState(() {
      _isGameActive = false;
    });
    _gameTimer?.cancel();
    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Masterpiece Complete! 🎨',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $_score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Perfect Hits: $_perfectHits',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Max Combo: $_combo',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Home'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Time Painter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Score',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _score.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_combo > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.bolt,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'x$_combo',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (_currentFeedback != null)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Text(
                      _currentFeedback!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            Expanded(
              child: GestureDetector(
                onTapDown: _onTapDown,
                child: Container(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      // Paint points
                      ...List.generate(_points.length, (index) {
                        final point = _points[index];
                        return Positioned(
                          left: point.position.dx - point.size / 2,
                          top: point.position.dy - point.size / 2,
                          child: Container(
                            width: point.size,
                            height: point.size,
                            decoration: BoxDecoration(
                              color: point.color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: point.color.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      // Timing circles
                      ...List.generate(_timingCircles.length, (index) {
                        final circle = _timingCircles[index];
                        return Positioned(
                          left: circle.position.dx - circle.size / 2,
                          top: circle.position.dy - circle.size / 2,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 1.0, end: 0.0),
                            duration: circle.shrinkDuration,
                            onEnd: () {
                              setState(() {
                                _timingCircles.remove(circle);
                              });
                            },
                            builder: (context, value, child) {
                              circle.currentSize = value * circle.size;
                              return Container(
                                width: circle.size,
                                height: circle.size,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: circle.color,
                                    width: 2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Transform.scale(
                                  scale: value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: circle.color.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            if (!_isGameActive)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Start Painting',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TimingCircle {
  final Offset position;
  final Color color;
  final double size;
  final Duration shrinkDuration;
  double currentSize;

  TimingCircle({
    required this.position,
    required this.color,
    required this.size,
    required this.shrinkDuration,
  }) : currentSize = size;
}

class PaintPoint {
  final Offset position;
  final Color color;
  final double size;

  PaintPoint({
    required this.position,
    required this.color,
    required this.size,
  });
}
