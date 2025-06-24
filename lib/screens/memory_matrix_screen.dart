import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../main.dart';

class MemoryMatrixScreen extends StatefulWidget {
  const MemoryMatrixScreen({super.key});

  @override
  State<MemoryMatrixScreen> createState() => _MemoryMatrixScreenState();
}

class _MemoryMatrixScreenState extends State<MemoryMatrixScreen>
    with TickerProviderStateMixin {
  // Game state
  bool _gameStarted = false;
  bool _gameOver = false;
  bool _showingPattern = false;
  int _score = 0;
  int _level = 1;
  int _patternLength = 3; // Initial pattern length

  // Grid state
  int _gridSize = 4; // 4x4 grid
  late List<bool> _gridState; // Current state of grid cells
  late List<int> _pattern; // Current pattern to remember
  late List<int> _playerInput; // Player's input pattern

  // Animation controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _gridAnimationController;
  late AnimationController _countdownAnimationController;

  // Timers
  Timer? _patternTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeGrid();
  }

  void _initializeAnimations() {
    // Background animation
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Grid animation
    _gridAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Countdown animation
    _countdownAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  void _initializeGrid() {
    // Initialize grid with all cells off
    _gridState = List.generate(_gridSize * _gridSize, (_) => false);

    // Initialize empty pattern and player input
    _pattern = [];
    _playerInput = [];
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _gameOver = false;
      _score = 0;
      _level = 1;
      _patternLength = 3;
      _initializeGrid();
    });

    // Start countdown animation
    _countdownAnimationController.forward();

    // Start first level after countdown
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _startLevel();
    });
  }

  void _startLevel() {
    // Generate new pattern
    _generatePattern();

    // Show pattern to player
    _showPattern();
  }

  void _generatePattern() {
    final random = math.Random();

    // Clear previous pattern
    _pattern.clear();

    // Generate new pattern with current length
    for (int i = 0; i < _patternLength; i++) {
      _pattern.add(random.nextInt(_gridSize * _gridSize));
    }

    // Clear player input
    _playerInput.clear();
  }

  void _showPattern() {
    setState(() {
      _showingPattern = true;

      // Reset all cells
      for (int i = 0; i < _gridState.length; i++) {
        _gridState[i] = false;
      }
    });

    // Show pattern sequence
    int index = 0;
    _patternTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (index >= _pattern.length) {
        timer.cancel();

        // Turn off all cells
        setState(() {
          for (int i = 0; i < _gridState.length; i++) {
            _gridState[i] = false;
          }
          _showingPattern = false;
        });
        return;
      }

      setState(() {
        // Turn off all cells
        for (int i = 0; i < _gridState.length; i++) {
          _gridState[i] = false;
        }

        // Turn on current cell in pattern
        _gridState[_pattern[index]] = true;
      });

      index++;
    });
  }

  void _onCellTap(int index) {
    if (_showingPattern || _gameOver) return;

    // Add to player input
    _playerInput.add(index);

    // Animate the tapped cell
    setState(() {
      _gridState[index] = true;
    });

    // Turn off after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _gridState[index] = false;
      });
    });

    // Check if the input matches the pattern so far
    if (_pattern[_playerInput.length - 1] !=
        _playerInput[_playerInput.length - 1]) {
      // Wrong input - game over
      _endGame();
      return;
    }

    // Check if the pattern is complete
    if (_playerInput.length == _pattern.length) {
      // Correct pattern - go to next level
      _levelComplete();
    }
  }

  void _levelComplete() {
    // Update score and level
    setState(() {
      _score += _patternLength * 10;
      _level++;

      // Increase pattern length every 2 levels
      if (_level % 2 == 0) {
        _patternLength++;
      }
    });

    // Show success feedback
    _showSuccessFeedback();

    // Start next level after a delay
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      _startLevel();
    });
  }

  void _showSuccessFeedback() {
    // Flash the grid with success color
    setState(() {
      for (int i = 0; i < _gridState.length; i++) {
        _gridState[i] = true;
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < _gridState.length; i++) {
          _gridState[i] = false;
        }
      });
    });
  }

  void _endGame() {
    _patternTimer?.cancel();

    setState(() {
      _gameOver = true;
    });

    // Show game over dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppDesign.elevatedSurfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFF8E94F2).withOpacity(0.3),
              width: 1,
            ),
          ),
          title: const Text(
            'Game Over',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your memory failed you at level $_level!',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              _buildStatItem(Icons.score_rounded, 'Score', '$_score'),
              const SizedBox(height: 8),
              _buildStatItem(Icons.trending_up_rounded, 'Level', '$_level'),
              const SizedBox(height: 8),
              _buildStatItem(
                  Icons.grid_view_rounded, 'Pattern Length', '$_patternLength'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: Text(
                'Play Again',
                style: TextStyle(
                  color: const Color(0xFF8E94F2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8E94F2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8E94F2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF8E94F2),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _resetGame() {
    _patternTimer?.cancel();

    setState(() {
      _gameStarted = false;
      _gameOver = false;
      _initializeGrid();
    });
  }

  @override
  void dispose() {
    _patternTimer?.cancel();
    _backgroundAnimationController.dispose();
    _gridAnimationController.dispose();
    _countdownAnimationController.dispose();
    super.dispose();
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
                    painter: MemoryMatrixBackgroundPainter(
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
                  // Game header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        IconButton(
                          onPressed: () {
                            if (_gameStarted && !_gameOver) {
                              // Show confirmation dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor:
                                      AppDesign.elevatedSurfaceColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: AppDesign.primaryColor
                                          .withOpacity(0.2),
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
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Quit'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Game stats
                        if (_gameStarted)
                          Row(
                            children: [
                              // Level indicator
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.trending_up_rounded,
                                      color: Color(0xFF8E94F2),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Level $_level',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Score
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.score_rounded,
                                      color: Color(0xFF8E94F2),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$_score',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Game content
                  Expanded(
                    child:
                        _gameStarted ? _buildGameGrid() : _buildStartScreen(),
                  ),

                  // Status message
                  if (_gameStarted && !_gameOver)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _showingPattern
                            ? 'Watch the pattern...'
                            : 'Repeat the pattern!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                                color: const Color(0xFF8E94F2).withOpacity(0.3),
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
                  Color(0xFF8E94F2),
                  Color(0xFF6A75E0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8E94F2).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.memory_rounded,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Game title
          const Text(
            'MEMORY MATRIX',
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
              'Watch the pattern, then recreate it from memory. How far can you go?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Difficulty selection
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDifficultyButton('3×3', 3),
              const SizedBox(width: 16),
              _buildDifficultyButton('4×4', 4),
              const SizedBox(width: 16),
              _buildDifficultyButton('5×5', 5),
            ],
          ),

          const SizedBox(height: 32),

          // Start button
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8E94F2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
              shadowColor: const Color(0xFF8E94F2).withOpacity(0.5),
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

  Widget _buildDifficultyButton(String label, int size) {
    final isSelected = _gridSize == size;

    return GestureDetector(
      onTap: () {
        setState(() {
          _gridSize = size;
          _initializeGrid();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8E94F2)
              : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildGameGrid() {
    final size = MediaQuery.of(context).size;
    final gridSize = math.min(size.width, size.height * 0.7) - 32;
    final cellSize = gridSize / _gridSize;

    return Center(
      child: SizedBox(
        width: gridSize,
        height: gridSize,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _gridSize,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _gridSize * _gridSize,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final isActive = _gridState[index];

            return GestureDetector(
              onTap: _showingPattern ? null : () => _onCellTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF8E94F2)
                      : Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white.withOpacity(0.1),
                    width: 2,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFF8E94F2).withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Background painter for the memory matrix game
class MemoryMatrixBackgroundPainter extends CustomPainter {
  final double animationValue;

  MemoryMatrixBackgroundPainter({required this.animationValue});

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

    // Draw a subtle grid pattern
    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        gridPaint,
      );
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        gridPaint,
      );
    }

    // Draw floating shapes
    for (int i = 0; i < 6; i++) {
      final x = size.width *
          (0.2 + 0.6 * math.sin(animationValue * math.pi * 0.2 + i * 0.7));
      final y = size.height *
          (0.2 + 0.6 * math.cos(animationValue * math.pi * 0.1 + i * 0.5));
      final size1 = 15.0 + 10.0 * math.sin(animationValue * math.pi * 2 + i);

      final shapePaint = Paint()
        ..color = const Color(0xFF8E94F2).withOpacity(0.05)
        ..style = PaintingStyle.fill;

      // Draw square
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y),
          width: size1,
          height: size1,
        ),
        shapePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MemoryMatrixBackgroundPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
