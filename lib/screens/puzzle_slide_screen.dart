import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../main.dart';

class PuzzleSlideScreen extends StatefulWidget {
  const PuzzleSlideScreen({super.key});

  @override
  State<PuzzleSlideScreen> createState() => _PuzzleSlideScreenState();
}

class _PuzzleSlideScreenState extends State<PuzzleSlideScreen>
    with TickerProviderStateMixin {
  // Game state
  bool _gameStarted = false;
  bool _gameOver = false;
  int _moves = 0;
  int _timeElapsed = 0;
  Timer? _timer;

  // Puzzle state
  late List<int?> _tiles;
  int _gridSize = 4; // 4x4 grid
  int? _emptyTileIndex;

  // Animation controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _tileAnimationController;

  // Tile animation state
  int? _movingTileIndex;
  Offset _movingTileStartPosition = Offset.zero;
  Offset _movingTileEndPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializePuzzle();
  }

  void _initializeAnimations() {
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _tileAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _tileAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          // Swap tiles in the grid
          if (_movingTileIndex != null && _emptyTileIndex != null) {
            _tiles[_emptyTileIndex!] = _tiles[_movingTileIndex!];
            _tiles[_movingTileIndex!] = null;
            _emptyTileIndex = _movingTileIndex;
            _movingTileIndex = null;
          }
        });

        // Check if puzzle is solved
        _checkIfSolved();
      }
    });
  }

  void _initializePuzzle() {
    // Create ordered list of tiles
    _tiles = List.generate(_gridSize * _gridSize, (index) {
      if (index == _gridSize * _gridSize - 1) {
        return null; // Empty tile
      }
      return index + 1;
    });

    _emptyTileIndex = _gridSize * _gridSize - 1;

    // Don't shuffle yet - wait for game to start
  }

  void _shufflePuzzle() {
    final random = Random();

    // Perform random valid moves to shuffle
    for (int i = 0; i < 100; i++) {
      final validMoves = _getValidMoveIndices();
      if (validMoves.isNotEmpty) {
        final randomMove = validMoves[random.nextInt(validMoves.length)];
        // Swap tiles without animation
        _tiles[_emptyTileIndex!] = _tiles[randomMove];
        _tiles[randomMove] = null;
        _emptyTileIndex = randomMove;
      }
    }

    // Reset moves counter
    _moves = 0;
  }

  List<int> _getValidMoveIndices() {
    if (_emptyTileIndex == null) return [];

    final validMoves = <int>[];
    final row = _emptyTileIndex! ~/ _gridSize;
    final col = _emptyTileIndex! % _gridSize;

    // Check up
    if (row > 0) {
      validMoves.add(_emptyTileIndex! - _gridSize);
    }

    // Check down
    if (row < _gridSize - 1) {
      validMoves.add(_emptyTileIndex! + _gridSize);
    }

    // Check left
    if (col > 0) {
      validMoves.add(_emptyTileIndex! - 1);
    }

    // Check right
    if (col < _gridSize - 1) {
      validMoves.add(_emptyTileIndex! + 1);
    }

    return validMoves;
  }

  void _moveTile(int index) {
    if (!_gameStarted || _gameOver) return;
    if (_tileAnimationController.isAnimating) return;

    // Check if the move is valid
    final validMoves = _getValidMoveIndices();
    if (!validMoves.contains(index)) return;

    setState(() {
      _movingTileIndex = index;
      _moves++;
    });

    // Start animation
    _tileAnimationController.reset();
    _tileAnimationController.forward();
  }

  void _startGame() {
    _shufflePuzzle();

    setState(() {
      _gameStarted = true;
      _gameOver = false;
      _moves = 0;
      _timeElapsed = 0;
    });

    // Start timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _timeElapsed++;
      });
    });
  }

  void _checkIfSolved() {
    // Check if all tiles are in correct position
    bool solved = true;

    for (int i = 0; i < _tiles.length - 1; i++) {
      if (_tiles[i] != i + 1) {
        solved = false;
        break;
      }
    }

    // Last tile should be empty
    if (_tiles[_tiles.length - 1] != null) {
      solved = false;
    }

    if (solved) {
      _endGame();
    }
  }

  void _endGame() {
    _timer?.cancel();

    setState(() {
      _gameOver = true;
    });

    // Show completion dialog
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
            'Puzzle Solved!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Congratulations! You solved the puzzle.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              _buildStatItem(
                  Icons.access_time_rounded, 'Time', _formatTime(_timeElapsed)),
              const SizedBox(height: 8),
              _buildStatItem(Icons.swap_horiz_rounded, 'Moves', '$_moves'),
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _resetGame() {
    _timer?.cancel();

    setState(() {
      _gameStarted = false;
      _gameOver = false;
      _initializePuzzle();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _backgroundAnimationController.dispose();
    _tileAnimationController.dispose();
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
                    painter: PuzzleBackgroundPainter(
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
                              // Moves counter
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
                                      Icons.swap_horiz_rounded,
                                      color: Color(0xFF8E94F2),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$_moves',
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

                              // Timer
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
                                      Icons.access_time_rounded,
                                      color: Color(0xFF8E94F2),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatTime(_timeElapsed),
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
                        _gameStarted ? _buildPuzzleGrid() : _buildStartScreen(),
                  ),
                ],
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
                Icons.grid_view_rounded,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Game title
          const Text(
            'PUZZLE SLIDE',
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
              'Arrange the tiles in order by sliding them into the empty space.',
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
          _initializePuzzle();
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

  Widget _buildPuzzleGrid() {
    final size = MediaQuery.of(context).size;
    final gridSize = min(size.width, size.height * 0.7) - 32;
    final tileSize = gridSize / _gridSize;

    return Center(
      child: SizedBox(
        width: gridSize,
        height: gridSize,
        child: Stack(
          children: [
            // Grid background
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),

            // Tiles
            ...List.generate(_tiles.length, (index) {
              final tile = _tiles[index];
              if (tile == null) return const SizedBox.shrink(); // Empty tile

              final row = index ~/ _gridSize;
              final col = index % _gridSize;

              // Check if this tile is currently being animated
              if (_movingTileIndex == index &&
                  _tileAnimationController.isAnimating) {
                return AnimatedBuilder(
                  animation: _tileAnimationController,
                  builder: (context, child) {
                    final emptyRow = _emptyTileIndex! ~/ _gridSize;
                    final emptyCol = _emptyTileIndex! % _gridSize;

                    final startX = col * tileSize;
                    final startY = row * tileSize;
                    final endX = emptyCol * tileSize;
                    final endY = emptyRow * tileSize;

                    final currentX = startX +
                        (endX - startX) * _tileAnimationController.value;
                    final currentY = startY +
                        (endY - startY) * _tileAnimationController.value;

                    return Positioned(
                      left: currentX,
                      top: currentY,
                      width: tileSize,
                      height: tileSize,
                      child: _buildTile(tile, tileSize),
                    );
                  },
                );
              }

              return Positioned(
                left: col * tileSize,
                top: row * tileSize,
                width: tileSize,
                height: tileSize,
                child: GestureDetector(
                  onTap: () => _moveTile(index),
                  child: _buildTile(tile, tileSize),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(int number, double size) {
    // Check if the tile is in the correct position
    final isCorrectPosition = _tiles.indexOf(number) == number - 1;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isCorrectPosition
                  ? const Color(0xFF8E94F2)
                  : const Color(0xFF6A75E0),
              isCorrectPosition
                  ? const Color(0xFF6A75E0)
                  : const Color(0xFF5964D0),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8E94F2).withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Background painter for the puzzle game
class PuzzleBackgroundPainter extends CustomPainter {
  final double animationValue;

  PuzzleBackgroundPainter({required this.animationValue});

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
    const spacing = 30.0;
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
    for (int i = 0; i < 5; i++) {
      final x = size.width * (0.2 + 0.6 * sin(animationValue * pi + i * 0.7));
      final y =
          size.height * (0.2 + 0.6 * cos(animationValue * pi * 0.5 + i * 0.5));
      final size1 = 20.0 + 10.0 * sin(animationValue * pi * 2 + i);
      final size2 = 40.0 + 20.0 * cos(animationValue * pi + i * 0.3);

      final shapePaint = Paint()
        ..color = const Color(0xFF8E94F2).withOpacity(0.05)
        ..style = PaintingStyle.fill;

      // Alternate between circles and squares
      if (i % 2 == 0) {
        canvas.drawCircle(
          Offset(x, y),
          size1,
          shapePaint,
        );
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, y),
            width: size2,
            height: size2,
          ),
          shapePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PuzzleBackgroundPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
