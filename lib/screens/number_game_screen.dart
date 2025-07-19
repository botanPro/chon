import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_header.dart';
import '../widgets/game_feedback.dart';
import '../widgets/prize_win_dialog.dart';
import '../widgets/game_action_button.dart';
import '../widgets/score_popup.dart';
import '../widgets/game_loading.dart';

class NumberGameScreen extends StatefulWidget {
  const NumberGameScreen({super.key});

  @override
  State<NumberGameScreen> createState() => _NumberGameScreenState();
}

class _NumberGameScreenState extends State<NumberGameScreen>
    with SingleTickerProviderStateMixin {
  late int _targetNumber;
  late TextEditingController _controller;
  int _attempts = 0;
  int _score = 0;
  int _timeLeft = 60;
  bool _isLoading = true;
  Timer? _timer;
  String _feedback = '';
  bool _isCorrect = false;
  int _combo = 0;
  final List<GlobalKey> _scorePopupKeys = [];
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 24.0).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );
    _initializeGame();
  }

  void _initializeGame() {
    _targetNumber = Random().nextInt(100) + 1;
    _controller.clear();
    _attempts = 0;
    _score = 0;
    _timeLeft = 60;
    _feedback = '';
    _isCorrect = false;
    _combo = 0;

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

  void _checkGuess() {
    if (_controller.text.isEmpty) return;

    int? guess = int.tryParse(_controller.text);
    if (guess == null || guess < 1 || guess > 100) {
      _showFeedback('Please enter a number between 1 and 100', false);
      _shakeController.forward(from: 0);
      return;
    }

    _attempts++;
    int difference = (_targetNumber - guess).abs();
    bool isClose = difference <= 5;

    if (guess == _targetNumber) {
      _handleCorrectGuess();
    } else {
      _handleIncorrectGuess(guess, difference, isClose);
    }

    _controller.clear();
  }

  void _handleCorrectGuess() {
    _isCorrect = true;
    _combo++;
    int points = 1000 * _combo;
    _score += points;

    _showFeedback('Perfect! You found the number!', true);
    _showScorePopup(points, 'Perfect Guess!', true);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _showWinDialog();
    });
  }

  void _handleIncorrectGuess(int guess, int difference, bool isClose) {
    String hint = guess < _targetNumber ? 'higher' : 'lower';
    int points = isClose ? 50 : 0;

    if (isClose) {
      _combo++;
      _score += points;
      _showScorePopup(points, 'Getting Closer!', true);
      _showFeedback('Very close! Try a little $hint', true);
    } else {
      _combo = 0;
      _showScorePopup(0, 'Try Again!', false);
      _showFeedback('Try $hint', false);
    }

    _shakeController.forward(from: 0);
  }

  void _showFeedback(String message, bool isPositive) {
    setState(() {
      _feedback = message;
      _isCorrect = isPositive;
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
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PrizeWinDialog(
        prize: 'MacBook Pro',
        score: _score,
        message:
            'You found the number in $_attempts attempts with ${60 - _timeLeft} seconds left!',
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
        message: 'Time\'s up! The number was $_targetNumber.',
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
    _controller.dispose();
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: GameLoading(
          message: 'Generating a number...',
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          GameHeader(
            score: _score,
            timeLeft: _timeLeft,
            moves: _attempts,
            onExit: () => Navigator.pop(context),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Guess the number between 1 and 100',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          sin(_shakeAnimation.value * pi / 12) * 8,
                          0,
                        ),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isCorrect
                              ? Colors.green
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.5),
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '?',
                        ),
                        onSubmitted: (_) => _checkGuess(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_feedback.isNotEmpty)
                    GameFeedback(
                      message: _feedback,
                      points: _isCorrect ? 1000 * _combo : 0,
                      isPositive: _isCorrect,
                      showCombo: true,
                      combo: _combo,
                    ),
                  const SizedBox(height: 32),
                  GameActionButton(
                    label: 'Guess',
                    icon: Icons.check_circle,
                    onPressed: _checkGuess,
                    showShine: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
