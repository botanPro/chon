import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../main.dart';
import '../widgets/game_header.dart';
import '../widgets/game_feedback.dart';
import '../widgets/combo_counter.dart';
import '../widgets/score_popup.dart';
import '../widgets/prize_win_dialog.dart';

class ReflexMasterScreen extends StatefulWidget {
  const ReflexMasterScreen({super.key});

  @override
  State<ReflexMasterScreen> createState() => _ReflexMasterScreenState();
}

class _ReflexMasterScreenState extends State<ReflexMasterScreen>
    with TickerProviderStateMixin {
  // Game state
  bool _gameStarted = false;
  bool _gameOver = false;
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _timeRemaining = 60; // 60 seconds game
  int _targetsMissed = 0;
  int _targetsHit = 0;

  // Target state
  double _targetX = 0;
  double _targetY = 0;
  double _targetSize = 80;
  Color _targetColor = Colors.red;

  // Animation controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _countdownAnimationController;
  late AnimationController _targetAnimationController;
  late Animation<double> _targetScaleAnimation;

  // Timers
  Timer? _gameTimer;
  Timer? _targetTimer;

  // Random generator
  final Random _random = Random();

  // List of possible target colors
  final List<Color> _targetColors = [
    const Color(0xFFFF5F5D), // Red
    const Color(0xFF96C3BC), // Teal
    const Color(0xFFF5B700), // Yellow
    const Color(0xFF8E94F2), // Purple
    const Color(0xFFFF9A76), // Orange
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Background animation
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Countdown animation
    _countdownAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Target animation
    _targetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _targetScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _targetAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _targetTimer?.cancel();
    _backgroundAnimationController.dispose();
    _countdownAnimationController.dispose();
    _targetAnimationController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _score = 0;
      _combo = 0;
      _maxCombo = 0;
      _timeRemaining = 60;
      _targetsMissed = 0;
      _targetsHit = 0;
    });

    // Start countdown animation
    _countdownAnimationController.forward();

    // Start game after countdown
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      _spawnTarget();

      // Start game timer
      _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          _timeRemaining--;

          if (_timeRemaining <= 0) {
            _endGame();
          }
        });
      });
    });
  }

  void _spawnTarget() {
    if (_gameOver) return;

    // Cancel previous target timer
    _targetTimer?.cancel();

    // Reset target animation
    _targetAnimationController.reset();

    // Generate random position for target
    setState(() {
      _targetX =
          _random.nextDouble() * 0.8 + 0.1; // Between 10% and 90% of width
      _targetY =
          _random.nextDouble() * 0.7 + 0.1; // Between 10% and 80% of height
      _targetSize = _random.nextDouble() * 40 + 60; // Between 60 and 100
      _targetColor = _targetColors[_random.nextInt(_targetColors.length)];
    });

    // Start target animation
    _targetAnimationController.forward();

    // Set timer for target disappearance (missed target)
    _targetTimer =
        Timer(Duration(milliseconds: 800 + _random.nextInt(700)), () {
      if (!mounted || _gameOver) return;

      setState(() {
        _targetsMissed++;
        _combo = 0; // Reset combo
      });

      _spawnTarget(); // Spawn next target
    });
  }

  void _hitTarget() {
    if (_gameOver) return;

    // Cancel target timer
    _targetTimer?.cancel();

    // Calculate score based on reaction time and combo
    final int basePoints = 100;
    final int comboBonus = _combo * 10;
    final int points = basePoints + comboBonus;

    setState(() {
      _score += points;
      _combo++;
      _targetsHit++;

      if (_combo > _maxCombo) {
        _maxCombo = _combo;
      }
    });

    // Show score popup at target position
    _showScorePopup(points);

    // Spawn next target
    _spawnTarget();
  }

  void _showScorePopup(int points) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate actual position
    final posX = _targetX * screenWidth;
    final posY = _targetY * screenHeight;

    // Show score popup
    ScorePopup.show(
      context: context,
      score: points,
      position: Offset(posX, posY),
      color: _targetColor,
    );
  }

  void _endGame() {
    _gameTimer?.cancel();
    _targetTimer?.cancel();

    setState(() {
      _gameOver = true;
    });

    // Calculate accuracy
    final double accuracy = _targetsHit > 0
        ? (_targetsHit / (_targetsHit + _targetsMissed)) * 100
        : 0;

    // Show game over dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PrizeWinDialog(
          score: _score,
          accuracy: accuracy,
          maxCombo: _maxCombo,
          onPlayAgain: () {
            Navigator.of(context).pop();
            _resetGame();
          },
          onGoHome: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      );
    });
  }

  void _resetGame() {
    setState(() {
      _gameStarted = false;
      _gameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation during active game
        if (_gameStarted && !_gameOver) {
          final bool shouldPop = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppDesign.elevatedSurfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppDesign.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              title: const Text(
                'Quit Game?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                'Are you sure you want to quit this game? Your progress will be lost.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesign.primaryColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Quit'),
                ),
              ],
            ),
          );
          return shouldPop;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppDesign.backgroundColor,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Animated background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _backgroundAnimationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ReflexGameBackgroundPainter(
                      animationValue: _backgroundAnimationController.value,
                    ),
                  );
                },
              ),
            ),

            // Game content
            SafeArea(
              child: Column(
                children: [
                  // Game header with score and timer
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Score display
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFF9A76),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$_score',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Timer display
                        if (_gameStarted && !_gameOver)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$_timeRemaining',
                                  style: TextStyle(
                                    color: _timeRemaining <= 10
                                        ? Colors.red
                                        : Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Game area
                  Expanded(
                    child:
                        _gameStarted ? _buildGameArea() : _buildStartScreen(),
                  ),
                ],
              ),
            ),

            // Countdown overlay
            if (_gameStarted && _countdownAnimationController.isAnimating)
              AnimatedBuilder(
                animation: _countdownAnimationController,
                builder: (context, child) {
                  final countdown =
                      3 - (_countdownAnimationController.value * 3).floor();
                  return Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.0, end: 0.0),
                      duration: const Duration(seconds: 1),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 1.0 + value,
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFF9A76).withOpacity(0.3),
                              ),
                              child: Center(
                                child: Text(
                                  countdown > 0 ? countdown.toString() : 'GO!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: countdown > 0 ? 60 : 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

            // Combo counter
            if (_gameStarted && _combo > 1)
              Positioned(
                top: 100,
                right: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF9A76),
                        const Color(0xFFE07E5F),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9A76).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.flash_on_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'COMBO x$_combo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Game logo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF9A76),
                  Color(0xFFE07E5F),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9A76).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.touch_app_rounded,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Game title
          const Text(
            'REFLEX MASTER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 16),

          // Game description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Tap the targets as quickly as possible. Build combos for bonus points!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Start button
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9A76),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
              shadowColor: const Color(0xFFFF9A76).withOpacity(0.5),
            ),
            child: const Text(
              'START GAME',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return GestureDetector(
      // When tapping anywhere except the target, register as a miss
      onTapDown: (details) {
        if (_countdownAnimationController.isAnimating || _gameOver) return;

        setState(() {
          _targetsMissed++;
          _combo = 0; // Reset combo
        });

        // Show feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Miss!'),
            backgroundColor: Colors.red,
            duration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Target
          if (!_countdownAnimationController.isAnimating && !_gameOver)
            Positioned(
              left: _targetX * MediaQuery.of(context).size.width -
                  _targetSize / 2,
              top: _targetY * MediaQuery.of(context).size.height -
                  _targetSize / 2,
              child: ScaleTransition(
                scale: _targetScaleAnimation,
                child: GestureDetector(
                  // When tapping the target specifically
                  onTapDown: (details) {
                    if (_gameOver) return;
                    _hitTarget();
                  },
                  child: Container(
                    width: _targetSize,
                    height: _targetSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _targetColor,
                      boxShadow: [
                        BoxShadow(
                          color: _targetColor.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: _targetSize * 0.6,
                        height: _targetSize * 0.6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: _targetSize * 0.3,
                            height: _targetSize * 0.3,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
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
    );
  }
}

// Background painter for the reflex game
class ReflexGameBackgroundPainter extends CustomPainter {
  final double animationValue;

  ReflexGameBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Create a rect for the entire canvas
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Create gradient background
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1A1A2E),
        Color(0xFF16213E),
        Color(0xFF0F3460),
        Color(0xFF0F3460),
      ],
    );

    // Draw the gradient
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Draw grid pattern
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    // Horizontal lines
    const spacing = 40.0;
    for (double i = 0; i < size.height; i += spacing) {
      final offset = 5 * sin((i / size.height + animationValue) * 2 * pi);
      canvas.drawLine(
        Offset(0, i + offset),
        Offset(size.width, i),
        gridPaint,
      );
    }

    // Vertical lines
    for (double i = 0; i < size.width; i += spacing) {
      final offset = 5 * cos((i / size.width + animationValue) * 2 * pi);
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + offset, size.height),
        gridPaint,
      );
    }

    // Draw some glowing circles
    for (int i = 0; i < 5; i++) {
      final x = size.width * (0.2 + 0.6 * sin(animationValue * pi + i * 0.7));
      final y =
          size.height * (0.2 + 0.6 * cos(animationValue * pi * 0.5 + i * 0.5));
      final radius = 50.0 + 20.0 * sin(animationValue * pi * 2 + i);

      final circlePaint = Paint()
        ..color = const Color(0xFFFF9A76).withOpacity(0.05)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        circlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ReflexGameBackgroundPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
