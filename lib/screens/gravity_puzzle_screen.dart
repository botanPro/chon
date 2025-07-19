import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GravityPuzzleScreen extends StatefulWidget {
  const GravityPuzzleScreen({super.key});

  @override
  State<GravityPuzzleScreen> createState() => _GravityPuzzleScreenState();
}

class _GravityPuzzleScreenState extends State<GravityPuzzleScreen>
    with TickerProviderStateMixin {
  late List<List<PuzzleTile>> _grid;
  final int _gridSize = 6;
  GravityDirection _currentGravity = GravityDirection.down;
  int _score = 0;
  int _moves = 0;
  int _level = 1;
  bool _isAnimating = false;
  Timer? _gravityTimer;
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _initializeGrid();
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: pi / 2).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );
  }

  void _initializeGrid() {
    _grid = List.generate(
      _gridSize,
      (i) => List.generate(
        _gridSize,
        (j) => PuzzleTile(
          type: _generateTileType(i, j),
          position: Position(i, j),
        ),
      ),
    );
  }

  TileType _generateTileType(int row, int col) {
    if (row == 0 && col == 0) return TileType.player;
    if (row == _gridSize - 1 && col == _gridSize - 1) return TileType.goal;
    if (Random().nextDouble() < 0.2) return TileType.block;
    if (Random().nextDouble() < 0.1) return TileType.crystal;
    return TileType.empty;
  }

  void _rotateGravity(GravityDirection newDirection) {
    if (_isAnimating) return;

    setState(() {
      _currentGravity = newDirection;
      _moves++;
      _isAnimating = true;
    });

    _rotateController.forward(from: 0).then((_) {
      _applyGravity();
    });
  }

  void _applyGravity() {
    bool hasMoved;
    _gravityTimer?.cancel();
    _gravityTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      hasMoved = false;
      setState(() {
        switch (_currentGravity) {
          case GravityDirection.down:
            hasMoved = _applyGravityDown();
            break;
          case GravityDirection.up:
            hasMoved = _applyGravityUp();
            break;
          case GravityDirection.left:
            hasMoved = _applyGravityLeft();
            break;
          case GravityDirection.right:
            hasMoved = _applyGravityRight();
            break;
        }
      });

      if (!hasMoved) {
        timer.cancel();
        setState(() {
          _isAnimating = false;
        });
        _checkWinCondition();
      }
    });
  }

  bool _applyGravityDown() {
    bool moved = false;
    for (int row = _gridSize - 2; row >= 0; row--) {
      for (int col = 0; col < _gridSize; col++) {
        if (_canMove(_grid[row][col]) &&
            _grid[row + 1][col].type == TileType.empty) {
          _swapTiles(row, col, row + 1, col);
          moved = true;
        }
      }
    }
    return moved;
  }

  bool _applyGravityUp() {
    bool moved = false;
    for (int row = 1; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if (_canMove(_grid[row][col]) &&
            _grid[row - 1][col].type == TileType.empty) {
          _swapTiles(row, col, row - 1, col);
          moved = true;
        }
      }
    }
    return moved;
  }

  bool _applyGravityLeft() {
    bool moved = false;
    for (int col = 1; col < _gridSize; col++) {
      for (int row = 0; row < _gridSize; row++) {
        if (_canMove(_grid[row][col]) &&
            _grid[row][col - 1].type == TileType.empty) {
          _swapTiles(row, col, row, col - 1);
          moved = true;
        }
      }
    }
    return moved;
  }

  bool _applyGravityRight() {
    bool moved = false;
    for (int col = _gridSize - 2; col >= 0; col--) {
      for (int row = 0; row < _gridSize; row++) {
        if (_canMove(_grid[row][col]) &&
            _grid[row][col + 1].type == TileType.empty) {
          _swapTiles(row, col, row, col + 1);
          moved = true;
        }
      }
    }
    return moved;
  }

  bool _canMove(PuzzleTile tile) {
    return tile.type == TileType.player || tile.type == TileType.crystal;
  }

  void _swapTiles(int row1, int col1, int row2, int col2) {
    final temp = _grid[row1][col1];
    _grid[row1][col1] = _grid[row2][col2];
    _grid[row2][col2] = temp;

    if (temp.type == TileType.crystal) {
      _grid[row1][col1] = PuzzleTile(
        type: TileType.empty,
        position: Position(row1, col1),
      );
      setState(() {
        _score += 100;
      });
    }
  }

  void _checkWinCondition() {
    // Find player position
    Position? playerPos;
    for (int i = 0; i < _gridSize; i++) {
      for (int j = 0; j < _gridSize; j++) {
        if (_grid[i][j].type == TileType.player) {
          playerPos = Position(i, j);
          break;
        }
      }
    }

    if (playerPos != null &&
        playerPos.row == _gridSize - 1 &&
        playerPos.col == _gridSize - 1) {
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    final levelBonus = (_gridSize * 100) - (_moves * 10);
    final totalScore = _score + levelBonus;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Level Complete! 🌟',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $totalScore',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Moves: $_moves',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Level Bonus: $levelBonus',
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
              setState(() {
                _level++;
                _moves = 0;
                _initializeGrid();
              });
            },
            child: const Text('Next Level'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gravityTimer?.cancel();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Gravity Puzzle'),
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
                          Icons.moving,
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
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _rotateAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _currentGravity == GravityDirection.right
                          ? _rotateAnimation.value
                          : _currentGravity == GravityDirection.left
                              ? -_rotateAnimation.value
                              : _currentGravity == GravityDirection.up
                                  ? pi
                                  : 0,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _gridSize,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: _gridSize * _gridSize,
                        itemBuilder: (context, index) {
                          final row = index ~/ _gridSize;
                          final col = index % _gridSize;
                          final tile = _grid[row][col];

                          return Container(
                            decoration: BoxDecoration(
                              color: _getTileColor(tile.type),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                if (tile.type != TileType.empty)
                                  BoxShadow(
                                    color: _getTileColor(tile.type)
                                        .withOpacity(0.5),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                              ],
                            ),
                            child: Center(
                              child: _getTileIcon(tile.type),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGravityButton(
                    GravityDirection.left,
                    Icons.arrow_left,
                  ),
                  _buildGravityButton(
                    GravityDirection.up,
                    Icons.arrow_upward,
                  ),
                  _buildGravityButton(
                    GravityDirection.down,
                    Icons.arrow_downward,
                  ),
                  _buildGravityButton(
                    GravityDirection.right,
                    Icons.arrow_right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGravityButton(GravityDirection direction, IconData icon) {
    final isSelected = _currentGravity == direction;
    return GestureDetector(
      onTap: () => _rotateGravity(direction),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Color _getTileColor(TileType type) {
    switch (type) {
      case TileType.empty:
        return Colors.grey.withOpacity(0.2);
      case TileType.player:
        return Colors.blue;
      case TileType.block:
        return Colors.grey;
      case TileType.crystal:
        return Colors.purple;
      case TileType.goal:
        return Colors.green;
    }
  }

  Widget _getTileIcon(TileType type) {
    switch (type) {
      case TileType.player:
        return const Icon(Icons.person, color: Colors.white);
      case TileType.block:
        return const Icon(Icons.stop, color: Colors.white);
      case TileType.crystal:
        return const Icon(Icons.diamond, color: Colors.white);
      case TileType.goal:
        return const Icon(Icons.flag, color: Colors.white);
      default:
        return const SizedBox();
    }
  }
}

enum GravityDirection { up, down, left, right }

enum TileType { empty, player, block, crystal, goal }

class PuzzleTile {
  final TileType type;
  final Position position;

  PuzzleTile({
    required this.type,
    required this.position,
  });
}

class Position {
  final int row;
  final int col;

  Position(this.row, this.col);
}
