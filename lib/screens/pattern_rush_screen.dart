import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class PatternRushScreen extends StatefulWidget {
  const PatternRushScreen({super.key});

  @override
  State<PatternRushScreen> createState() => _PatternRushScreenState();
}

class _PatternRushScreenState extends State<PatternRushScreen>
    with TickerProviderStateMixin {
  final int _gridSize = 3;
  late List<List<PatternTile>> _grid;
  List<Position> _pattern = [];
  List<Position> _playerPattern = [];
  int _level = 1;
  int _score = 0;
  bool _isShowingPattern = false;
  bool _canInput = false;
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final List<Color> _tileColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    _initializeGrid();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startLevel();
  }

  void _initializeGrid() {
    _grid = List.generate(
      _gridSize,
      (i) => List.generate(
        _gridSize,
        (j) => PatternTile(
          color: _tileColors[Random().nextInt(_tileColors.length)],
          position: Position(i, j),
        ),
      ),
    );
  }

  void _startLevel() {
    setState(() {
      _isShowingPattern = true;
      _canInput = false;
      _playerPattern = [];
      _pattern = _generatePattern();
    });
    _showPattern();
  }

  List<Position> _generatePattern() {
    final pattern = <Position>[];
    final patternLength = _level + 2;

    for (int i = 0; i < patternLength; i++) {
      pattern.add(Position(
        Random().nextInt(_gridSize),
        Random().nextInt(_gridSize),
      ));
    }
    return pattern;
  }

  Future<void> _showPattern() async {
    await Future.delayed(const Duration(milliseconds: 500));

    for (final pos in _pattern) {
      setState(() {
        _grid[pos.row][pos.col].isHighlighted = true;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _grid[pos.row][pos.col].isHighlighted = false;
      });
      await Future.delayed(const Duration(milliseconds: 200));
    }

    setState(() {
      _isShowingPattern = false;
      _canInput = true;
    });
  }

  void _onTileTap(int row, int col) {
    if (!_canInput || _isShowingPattern) return;

    final position = Position(row, col);
    setState(() {
      _playerPattern.add(position);
      _grid[row][col].isHighlighted = true;
    });
    _pulseController.forward().then((_) => _pulseController.reverse());

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _grid[row][col].isHighlighted = false;
      });
    });

    if (_playerPattern.length == _pattern.length) {
      _checkPattern();
    }
  }

  void _checkPattern() {
    bool isCorrect = true;
    for (int i = 0; i < _pattern.length; i++) {
      if (_pattern[i] != _playerPattern[i]) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      _onSuccess();
    } else {
      _onFailure();
    }
  }

  void _onSuccess() {
    final points = _level * 100;
    setState(() {
      _score += points;
      _level++;
    });
    _shakeController.forward().then((_) => _shakeController.reverse());
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Perfect! 🎉',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Level $_level Complete',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $_score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startLevel();
            },
            child: const Text('Next Level'),
          ),
        ],
      ),
    );
  }

  void _onFailure() {
    _showFailureDialog();
  }

  void _showFailureDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Game Over! 💔',
          style: TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You reached Level $_level',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Final Score: $_score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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
              setState(() {
                _level = 1;
                _score = 0;
                _startLevel();
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Pattern Rush'),
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
                      AnimatedBuilder(
                        animation: _shakeController,
                        builder: (context, child) {
                          final shake =
                              sin(_shakeController.value * 2 * pi) * 5;
                          return Transform.translate(
                            offset: Offset(shake, 0),
                            child: Text(
                              _score.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
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
                          Icons.speed,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Level $_level',
                          style: const TextStyle(
                            color: Colors.white,
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
            const SizedBox(height: 32),
            Text(
              _isShowingPattern
                  ? 'Watch the pattern...'
                  : _canInput
                      ? 'Repeat the pattern!'
                      : 'Get ready...',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(32),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _gridSize,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _gridSize * _gridSize,
                itemBuilder: (context, index) {
                  final row = index ~/ _gridSize;
                  final col = index % _gridSize;
                  final tile = _grid[row][col];

                  return GestureDetector(
                    onTap: () => _onTileTap(row, col),
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale:
                              tile.isHighlighted ? _pulseAnimation.value : 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: tile.isHighlighted
                                  ? tile.color
                                  : tile.color.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: tile.isHighlighted
                                  ? [
                                      BoxShadow(
                                        color: tile.color.withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PatternTile {
  final Color color;
  final Position position;
  bool isHighlighted;

  PatternTile({
    required this.color,
    required this.position,
    this.isHighlighted = false,
  });
}

class Position {
  final int row;
  final int col;

  Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}
