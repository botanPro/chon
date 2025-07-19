import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/memory_card.dart';
import '../widgets/game_header.dart';
import '../widgets/game_feedback.dart';
import '../widgets/prize_win_dialog.dart';
import '../widgets/combo_counter.dart';
import '../widgets/score_popup.dart';
import '../widgets/game_loading.dart';
import '../utils/responsive_utils.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<String> _emojis = ['🚗', '💻', '📱', '🎮', '🎨', '🎧', '⌚️', '🔊'];
  late List<String> _cards;
  List<int> _flippedCards = [];
  List<int> _matchedCards = [];
  int _moves = 0;
  int _score = 0;
  int _combo = 0;
  int _timeLeft = 120;
  bool _isLoading = true;
  Timer? _timer;
  final List<GlobalKey> _scorePopupKeys = [];
  bool _canFlip = true;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _cards = [..._emojis, ..._emojis];
    _cards.shuffle();
    _flippedCards = [];
    _matchedCards = [];
    _moves = 0;
    _score = 0;
    _combo = 0;
    _timeLeft = 120;
    _canFlip = true;

    // Simulate loading
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() => _isLoading = false);
      _startTimer();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _showGameOver();
        }
      });
    });
  }

  void _onCardTap(int index) {
    if (!_canFlip ||
        _flippedCards.contains(index) ||
        _matchedCards.contains(index)) return;

    setState(() {
      _flippedCards.add(index);
    });

    if (_flippedCards.length == 2) {
      _canFlip = false;
      _moves++;

      if (_cards[_flippedCards[0]] == _cards[_flippedCards[1]]) {
        // Match found
        _handleMatch();
      } else {
        // No match
        _handleMismatch();
      }
    }
  }

  void _handleMatch() {
    _combo++;
    int points = 100 * _combo;
    _score += points;

    // Show score popup
    _showScorePopup(points, 'Perfect Match!', true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _matchedCards.addAll(_flippedCards);
        _flippedCards = [];
        _canFlip = true;
      });

      if (_matchedCards.length == _cards.length) {
        _timer?.cancel();
        _showWinDialog();
      }
    });
  }

  void _handleMismatch() {
    _combo = 0;
    _showScorePopup(0, 'Try Again!', false);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        _flippedCards = [];
        _canFlip = true;
      });
    });
  }

  void _showScorePopup(int points, String message, bool isPositive) {
    final key = GlobalKey();
    _scorePopupKeys.add(key);

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + renderBox.size.height / 2 - 100,
        left: position.dx + renderBox.size.width / 2 - 50,
        child: ScorePopup(
          key: key,
          points: points,
          message: message,
          isPositive: isPositive,
          onComplete: () {
            entry.remove();
            _scorePopupKeys.remove(key);
          },
        ),
      ),
    );

    overlay.insert(entry);
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PrizeWinDialog(
        prize: 'Tesla Model 3',
        score: _score,
        message:
            'You completed the game in $_moves moves with ${120 - _timeLeft} seconds!',
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() {
            _isLoading = true;
            _initializeGame();
          });
        },
        onHome: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PrizeWinDialog(
        prize: 'Better luck next time!',
        score: _score,
        message: 'Time\'s up! You matched ${_matchedCards.length ~/ 2} pairs.',
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() {
            _isLoading = true;
            _initializeGame();
          });
        },
        onHome: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: GameLoading(
          message: 'Shuffling cards...',
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          GameHeader(
            score: _score,
            timeLeft: _timeLeft,
            moves: _moves,
            onExit: () => Navigator.pop(context),
          ),
          Expanded(
            child: Stack(
              children: [
                GridView.builder(
                  padding: ResponsiveUtils.getResponsivePadding(context),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveUtils.getGridCount(context,
                        mobile: 4, tablet: 4, desktop: 4),
                    crossAxisSpacing:
                        ResponsiveUtils.getResponsiveSpacing(context),
                    mainAxisSpacing:
                        ResponsiveUtils.getResponsiveSpacing(context),
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) => MemoryCard(
                    emoji: _cards[index],
                    isFlipped: _flippedCards.contains(index) ||
                        _matchedCards.contains(index),
                    isMatched: _matchedCards.contains(index),
                    onTap: () => _onCardTap(index),
                  ),
                ),
                if (_combo > 1)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: ComboCounter(
                      combo: _combo,
                      multiplier: _combo,
                    ),
                  ),
                if (_flippedCards.length == 2)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GameFeedback(
                        message:
                            _cards[_flippedCards[0]] == _cards[_flippedCards[1]]
                                ? 'Perfect Match!'
                                : 'Try Again!',
                        points:
                            _cards[_flippedCards[0]] == _cards[_flippedCards[1]]
                                ? 100 * _combo
                                : 0,
                        isPositive: _cards[_flippedCards[0]] ==
                            _cards[_flippedCards[1]],
                        showCombo: true,
                        combo: _combo,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
