import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ColorChainScreen extends StatefulWidget {
  const ColorChainScreen({super.key});

  @override
  State<ColorChainScreen> createState() => _ColorChainScreenState();
}

class _ColorChainScreenState extends State<ColorChainScreen>
    with TickerProviderStateMixin {
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  late List<List<ColorTile>> _grid;
  final int _gridSize = 8;
  int _score = 0;
  int _multiplier = 1;
  int _chainLength = 0;
  Timer? _multiplierTimer;
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isSelecting = false;
  List<Position> _selectedTiles = [];
  final List<String> _encouragements = [
    'Great! 🎯',
    'Amazing! ⭐️',
    'Fantastic! 🔥',
    'Incredible! ⚡️',
    'Unstoppable! 🚀',
    'Legendary! 👑',
  ];
  String? _currentEncouragement;

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
  }

  void _initializeGrid() {
    _grid = List.generate(
      _gridSize,
      (i) => List.generate(
        _gridSize,
        (j) => ColorTile(
          color: _colors[Random().nextInt(_colors.length)],
          position: Position(i, j),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final pos = _getTilePosition(localPosition);
    if (pos != null) {
      setState(() {
        _isSelecting = true;
        _selectedTiles = [pos];
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isSelecting) return;
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final pos = _getTilePosition(localPosition);

    if (pos != null && _isValidMove(pos)) {
      setState(() {
        _selectedTiles.add(pos);
        _chainLength = _selectedTiles.length;
      });
      _pulseController.forward().then((_) => _pulseController.reverse());
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_selectedTiles.length >= 3) {
      _processChain();
    }
    setState(() {
      _isSelecting = false;
      _selectedTiles = [];
      _chainLength = 0;
    });
  }

  bool _isValidMove(Position pos) {
    if (_selectedTiles.isEmpty) return true;
    if (_selectedTiles.contains(pos)) return false;

    final last = _selectedTiles.last;
    final color = _grid[last.row][last.col].color;

    if (_grid[pos.row][pos.col].color != color) return false;

    final rowDiff = (pos.row - last.row).abs();
    final colDiff = (pos.col - last.col).abs();
    return (rowDiff <= 1 && colDiff <= 1) &&
        (rowDiff + colDiff == 1 || rowDiff + colDiff == 2);
  }

  Position? _getTilePosition(Offset localPosition) {
    final tileSize = MediaQuery.of(context).size.width / _gridSize;
    final row = (localPosition.dy / tileSize).floor();
    final col = (localPosition.dx / tileSize).floor();

    if (row >= 0 && row < _gridSize && col >= 0 && col < _gridSize) {
      return Position(row, col);
    }
    return null;
  }

  void _processChain() {
    final points = _selectedTiles.length * 100 * _multiplier;
    setState(() {
      _score += points;
      _multiplier = min(_multiplier + 1, 10);
      _currentEncouragement =
          _encouragements[min((_multiplier - 1), _encouragements.length - 1)];
    });

    // Replace matched tiles and drop tiles above
    for (final pos in _selectedTiles) {
      for (int i = pos.row; i > 0; i--) {
        _grid[i][pos.col] = _grid[i - 1][pos.col];
      }
      _grid[0][pos.col] = ColorTile(
        color: _colors[Random().nextInt(_colors.length)],
        position: Position(0, pos.col),
      );
    }

    _shakeController.forward().then((_) => _shakeController.reverse());

    // Reset multiplier after 2 seconds of inactivity
    _multiplierTimer?.cancel();
    _multiplierTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _multiplier = 1;
        _currentEncouragement = null;
      });
    });
  }

  @override
  void dispose() {
    _multiplierTimer?.cancel();
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tileSize = MediaQuery.of(context).size.width / _gridSize;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Color Chain'),
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
                          Icons.bolt,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_multiplier}x',
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
            if (_currentEncouragement != null)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Text(
                      _currentEncouragement!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            Expanded(
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Container(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _gridSize,
                        ),
                        itemCount: _gridSize * _gridSize,
                        itemBuilder: (context, index) {
                          final row = index ~/ _gridSize;
                          final col = index % _gridSize;
                          final tile = _grid[row][col];
                          final isSelected =
                              _selectedTiles.contains(Position(row, col));

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.all(isSelected ? 4 : 2),
                            decoration: BoxDecoration(
                              color: tile.color,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    )
                                  : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: tile.color.withOpacity(0.5),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        },
                      ),
                      if (_chainLength >= 3)
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '+${_chainLength * 100 * _multiplier}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(
                                  Icons.stars,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
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

class ColorTile {
  final Color color;
  final Position position;

  ColorTile({
    required this.color,
    required this.position,
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
