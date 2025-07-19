import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_button.dart';

class WordTowerScreen extends StatefulWidget {
  const WordTowerScreen({super.key});

  @override
  State<WordTowerScreen> createState() => _WordTowerScreenState();
}

class _WordTowerScreenState extends State<WordTowerScreen>
    with TickerProviderStateMixin {
  final List<String> _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
  final List<String> _vowels = 'AEIOU'.split('');
  late List<List<String>> _grid;
  final int _gridSize = 5;
  List<Position> _selectedTiles = [];
  String _currentWord = '';
  int _score = 0;
  int _combo = 0;
  Timer? _comboTimer;
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final Map<int, String> _specialEffects = {
    5: '🌟 Power Word!',
    6: '⚡️ Super Word!',
    7: '🔥 Mega Word!',
    8: '💫 Ultra Word!',
    9: '👑 Royal Word!',
    10: '🌈 Legendary Word!',
  };
  String? _currentEffect;
  List<WordTower> _towers = [];

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
        (j) {
          if (Random().nextDouble() < 0.3) {
            return _vowels[Random().nextInt(_vowels.length)];
          }
          return _letters[Random().nextInt(_letters.length)];
        },
      ),
    );
  }

  void _onTileTap(int row, int col) {
    if (_selectedTiles.contains(Position(row, col))) {
      setState(() {
        final index = _selectedTiles.indexOf(Position(row, col));
        _selectedTiles = _selectedTiles.sublist(0, index + 1);
        _currentWord = _buildWord();
      });
      return;
    }

    if (!_isValidMove(row, col)) return;

    setState(() {
      _selectedTiles.add(Position(row, col));
      _currentWord = _buildWord();
    });
    _pulseController.forward().then((_) => _pulseController.reverse());
  }

  bool _isValidMove(int row, int col) {
    if (_selectedTiles.isEmpty) return true;
    final last = _selectedTiles.last;
    final rowDiff = (row - last.row).abs();
    final colDiff = (col - last.col).abs();
    return (rowDiff <= 1 && colDiff <= 1);
  }

  String _buildWord() {
    return _selectedTiles.map((pos) => _grid[pos.row][pos.col]).join();
  }

  void _submitWord() {
    if (_currentWord.length < 3) {
      _resetSelection();
      return;
    }

    // In a real app, we would check against a dictionary
    final wordLength = _currentWord.length;
    final points = pow(2, wordLength).toInt() * (1 + _combo);

    setState(() {
      _score += points;
      _combo++;
      if (wordLength >= 5) {
        _currentEffect = _specialEffects[min(wordLength, 10)];
        _addTower(wordLength);
      }
    });

    _shakeController.forward().then((_) => _shakeController.reverse());

    // Reset combo after 3 seconds of inactivity
    _comboTimer?.cancel();
    _comboTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _combo = 0;
        _currentEffect = null;
      });
    });

    // Replace used letters
    for (final pos in _selectedTiles) {
      setState(() {
        if (Random().nextDouble() < 0.3) {
          _grid[pos.row][pos.col] = _vowels[Random().nextInt(_vowels.length)];
        } else {
          _grid[pos.row][pos.col] = _letters[Random().nextInt(_letters.length)];
        }
      });
    }

    _resetSelection();
  }

  void _addTower(int height) {
    final tower = WordTower(
      word: _currentWord,
      height: height,
      color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
    );
    setState(() {
      _towers.add(tower);
      if (_towers.length > 5) {
        _towers.removeAt(0);
      }
    });
  }

  void _resetSelection() {
    setState(() {
      _selectedTiles = [];
      _currentWord = '';
    });
  }

  @override
  void dispose() {
    _comboTimer?.cancel();
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Word Tower'),
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
                            Icons.local_fire_department,
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
            if (_currentEffect != null)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Text(
                      _currentEffect!,
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
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _towers.length,
                itemBuilder: (context, index) {
                  final tower = _towers[index];
                  return Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: tower.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          tower.word,
                          style: TextStyle(
                            color: tower.color,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          height: tower.height * 10.0,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: tower.color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _gridSize,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _gridSize * _gridSize,
                itemBuilder: (context, index) {
                  final row = index ~/ _gridSize;
                  final col = index % _gridSize;
                  final isSelected =
                      _selectedTiles.contains(Position(row, col));

                  return GestureDetector(
                    onTap: () => _onTileTap(row, col),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          _grid[row][col],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 24,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _currentWord.isEmpty ? 'Form a word' : _currentWord,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GameButton(
                          text: 'Clear',
                          onPressed: _resetSelection,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GameButton(
                          text: 'Submit',
                          onPressed: _submitWord,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WordTower {
  final String word;
  final int height;
  final Color color;

  WordTower({
    required this.word,
    required this.height,
    required this.color,
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
