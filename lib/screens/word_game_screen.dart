import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_header.dart';
import '../widgets/game_feedback.dart';
import '../widgets/prize_win_dialog.dart';
import '../widgets/game_action_button.dart';
import '../widgets/score_popup.dart';
import '../widgets/game_loading.dart';
import '../widgets/combo_counter.dart';

class WordGameScreen extends StatefulWidget {
  const WordGameScreen({super.key});

  @override
  State<WordGameScreen> createState() => _WordGameScreenState();
}

class _WordGameScreenState extends State<WordGameScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> _words = [
    {'word': 'FLUTTER', 'hint': 'A framework for building beautiful apps'},
    {'word': 'MOBILE', 'hint': 'Portable devices'},
    {'word': 'CODING', 'hint': 'Writing instructions for computers'},
    {'word': 'WIDGET', 'hint': 'Building blocks of Flutter UI'},
    {'word': 'DESIGN', 'hint': 'Making things look beautiful'},
    {'word': 'SCREEN', 'hint': 'Display interface'},
    {'word': 'BUTTON', 'hint': 'Clickable element'},
    {'word': 'SCROLL', 'hint': 'Moving content up and down'},
    {'word': 'LAYOUT', 'hint': 'Arrangement of elements'},
    {'word': 'GESTURE', 'hint': 'Touch interaction'},
  ];

  late String _currentWord;
  late String _scrambledWord;
  late String _hint;
  late TextEditingController _controller;
  int _score = 0;
  int _timeLeft = 90;
  int _wordsGuessed = 0;
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
    _words.shuffle();
    _wordsGuessed = 0;
    _score = 0;
    _timeLeft = 90;
    _combo = 0;
    _selectNewWord();

    // Simulate loading
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() => _isLoading = false);
      _startTimer();
    });
  }

  void _selectNewWord() {
    final wordData = _words[_wordsGuessed % _words.length];
    _currentWord = wordData['word']!;
    _hint = wordData['hint']!;
    _scrambledWord = _scrambleWord(_currentWord);
    _controller.clear();
    _feedback = '';
    _isCorrect = false;
  }

  String _scrambleWord(String word) {
    List<String> letters = word.split('');
    String scrambled;
    do {
      letters.shuffle();
      scrambled = letters.join();
    } while (scrambled == word);
    return scrambled;
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

  void _checkAnswer() {
    if (_controller.text.isEmpty) return;

    String guess = _controller.text.toUpperCase();
    if (guess == _currentWord) {
      _handleCorrectAnswer();
    } else {
      _handleIncorrectAnswer();
    }
  }

  void _handleCorrectAnswer() {
    _combo++;
    int basePoints = _currentWord.length * 100;
    int points = basePoints * _combo;
    _score += points;
    _wordsGuessed++;
    _isCorrect = true;

    _showFeedback('Perfect! Moving to next word...', true);
    _showScorePopup(points, 'Word Solved!', true);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_wordsGuessed == _words.length) {
        _showWinDialog();
      } else {
        setState(() {
          _selectNewWord();
        });
      }
    });
  }

  void _handleIncorrectAnswer() {
    _combo = 0;
    _showFeedback('Try again!', false);
    _showScorePopup(0, 'Keep trying!', false);
    _shakeController.forward(from: 0);
    _controller.clear();
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
          score: points,
          color: isPositive ? Colors.green : Colors.red,
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
        prize: 'iPhone 15 Pro',
        score: _score,
        accuracy: 100.0,
        maxCombo: _combo,
        message: 'You solved all words with ${_timeLeft} seconds left!',
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() {
            _isLoading = true;
            _initializeGame();
          });
        },
        onGoHome: () {
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
        accuracy: (_wordsGuessed / _words.length) * 100,
        maxCombo: _combo,
        message: 'Time\'s up! You solved $_wordsGuessed words.',
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() {
            _isLoading = true;
            _initializeGame();
          });
        },
        onGoHome: () {
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
          message: 'Scrambling words...',
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          GameHeader(
            score: _score,
            timeLeft: _timeLeft,
            level: _wordsGuessed + 1,
            onExit: () => Navigator.pop(context),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Unscramble the word',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _scrambledWord,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hint: $_hint',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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
                      width: 300,
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
                        textCapitalization: TextCapitalization.characters,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: 4,
                            ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type your answer',
                        ),
                        onSubmitted: (_) => _checkAnswer(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_feedback.isNotEmpty)
                    GameFeedback(
                      message: _feedback,
                      points:
                          _isCorrect ? _currentWord.length * 100 * _combo : 0,
                      isPositive: _isCorrect,
                      showCombo: true,
                      combo: _combo,
                    ),
                  const SizedBox(height: 32),
                  GameActionButton(
                    label: 'Check',
                    icon: Icons.check_circle,
                    onPressed: _checkAnswer,
                    showShine: true,
                  ),
                ],
              ),
            ),
          ),
          if (_combo > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ComboCounter(
                combo: _combo,
                multiplier: _combo,
              ),
            ),
        ],
      ),
    );
  }
}
