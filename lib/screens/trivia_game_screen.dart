import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class TriviaGameScreen extends StatefulWidget {
  const TriviaGameScreen({super.key});

  @override
  State<TriviaGameScreen> createState() => _TriviaGameScreenState();
}

class _TriviaGameScreenState extends State<TriviaGameScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _selectedAnswerIndex = -1;
  int _timeRemaining = 30;
  int _correctAnswers = 0;
  late Timer _timer;
  bool _showGameOver = false;
  final int _onlinePlayers = 20000; // Dummy data

  // Animation controllers
  late AnimationController _optionsAnimationController;
  late AnimationController _questionAnimationController;
  late AnimationController _gameOverAnimationController;

  // Animations
  late Animation<double> _questionFadeAnimation;
  late Animation<Offset> _questionSlideAnimation;
  late Animation<double> _gameOverFadeAnimation;

  // Dummy winners data
  final List<Map<String, dynamic>> _winners = [
    {
      'rank': 'Top 1',
      'name': 'Bashdar',
      'lastName': 'Hakim',
      'phone': '+964 750 000 0000',
      'isUser': false,
    },
    {
      'rank': 'Top 1',
      'name': 'Bashdar',
      'lastName': 'Hakim',
      'phone': '+964 750 000 0000',
      'isUser': false,
    },
    {
      'rank': 'Top 3',
      'name': 'You',
      'lastName': '',
      'phone': '+964 750 000 0000',
      'isUser': true,
    },
    {
      'rank': 'Top 1',
      'name': 'Bashdar',
      'lastName': 'Hakim',
      'phone': '+964 750 000 0000',
      'isUser': false,
    },
    {
      'rank': 'Top 1',
      'name': 'Bashdar',
      'lastName': 'Hakim',
      'phone': '+964 750 000 0000',
      'isUser': false,
    },
    {
      'rank': 'Top 1',
      'name': 'Bashdar',
      'lastName': 'Hakim',
      'phone': '+964 750 000 0000',
      'isUser': false,
    },
    {
      'rank': 'Top 1',
      'name': 'Bashdar',
      'lastName': 'Hakim',
      'phone': '+964 750 000 0000',
      'isUser': false,
    },
    {
      'rank': 'Top 1',
      'name': 'Bashdar',
      'lastName': 'Hakim',
      'phone': '+964 750 000 0000',
      'isUser': false,
    },
  ];

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'just a random question most be here ?',
      'options': [
        'Just a random text here',
        'Just a random text here',
        'Just a random text here',
        'Just a random text here',
      ],
      'difficulty': 'Difficult Level',
      'correctAnswer': 0,
    },
    {
      'question': 'Which planet is known as the Red Planet?',
      'options': [
        'Venus',
        'Mars',
        'Jupiter',
        'Saturn',
      ],
      'difficulty': 'Medium Level',
      'correctAnswer': 1,
    },
    {
      'question': 'What is the capital of France?',
      'options': [
        'London',
        'Berlin',
        'Paris',
        'Madrid',
      ],
      'difficulty': 'Easy Level',
      'correctAnswer': 2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startTimer();
    _questionAnimationController.forward();
    _optionsAnimationController.forward();
  }

  void _initializeAnimations() {
    // Question animations
    _questionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _questionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _questionAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _questionSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _questionAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Options animations
    _optionsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Game over animations
    _gameOverAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _gameOverFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _gameOverAnimationController,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _questionAnimationController.dispose();
    _optionsAnimationController.dispose();
    _gameOverAnimationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _timer.cancel();
        _goToNextQuestion();
      }
    });
  }

  void _goToNextQuestion() {
    // Check if the selected answer was correct
    if (_selectedAnswerIndex != -1 &&
        _selectedAnswerIndex ==
            _questions[_currentQuestionIndex]['correctAnswer']) {
      _correctAnswers++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      // Reset animations
      _questionAnimationController.reset();
      _optionsAnimationController.reset();

      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = -1;
        _timeRemaining = 30;
      });

      // Start animations for next question
      _questionAnimationController.forward();
      _optionsAnimationController.forward();
      _startTimer();
    } else {
      // Game over
      _timer.cancel();

      // Add game result to history
      _addGameResultToHistory();

      setState(() {
        _showGameOver = true;
      });
      _gameOverAnimationController.forward();
    }
  }

  void _addGameResultToHistory() {
    final authService = Provider.of<AuthService>(context, listen: false);

    // Calculate position based on score
    String position;
    double winAmount = 0.0;

    final scorePercentage = _correctAnswers / _questions.length;

    if (scorePercentage == 1.0) {
      position = 'Top 1';
      winAmount = 50.0;
    } else if (scorePercentage >= 0.8) {
      position = 'Top 3';
      winAmount = 25.0;
    } else if (scorePercentage >= 0.6) {
      position = 'Top 5';
      winAmount = 10.0;
    } else if (scorePercentage >= 0.4) {
      position = 'Top 10';
      winAmount = 5.0;
    } else {
      position = 'Top 20';
      winAmount = 0.0;
    }

    // Create and add the game result
    final gameResult = GameResult(
      gameType: 'Trivia Challenge',
      position: position,
      score: _correctAnswers,
      totalQuestions: _questions.length,
      winAmount: winAmount,
      timestamp: DateTime.now(),
    );

    authService.addGameResult(gameResult);
  }

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswerIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E0D),
      body: SafeArea(
        child: _showGameOver ? _buildWinnersScreen() : _buildGameScreen(),
      ),
    );
  }

  Widget _buildGameScreen() {
    final question = _questions[_currentQuestionIndex];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF0066FF),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(4),
      child: Column(
        children: [
          _buildHeader(),
          _buildProgressBar(),
          _buildQuestionSection(question),
          _buildOptionsSection(question),
          _buildNextButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWinnersScreen() {
    return FadeTransition(
      opacity: _gameOverFadeAnimation,
      child: Container(
        color: const Color(0xFF0A0E0D),
        child: Column(
          children: [
            // App bar with back button and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Winners',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Empty space to balance the back button
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Winners list
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _winners.length,
                itemBuilder: (context, index) {
                  final winner = _winners[index];
                  final bool isUser = winner['isUser'] as bool;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF151918),
                        borderRadius: BorderRadius.circular(16),
                        border: isUser
                            ? Border.all(
                                color: const Color(0xFF94C1BA).withOpacity(0.5),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Rank and badge
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  winner['rank'],
                                  style: const TextStyle(
                                    color: Color(0xFF94C1BA),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF94C1BA)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.military_tech,
                                        color: Color(0xFF94C1BA),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'MG 5 Silver',
                                        style: TextStyle(
                                          color: Color(0xFF94C1BA),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),

                            // User info and avatar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isUser ? 'You' : winner['name'],
                                      style: TextStyle(
                                        color: isUser
                                            ? const Color(0xFF94C1BA)
                                            : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (!isUser)
                                      Text(
                                        ' ${winner['lastName']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  winner['phone'],
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 12),

                            // Avatar
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF00B894),
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  'assets/images/avatar.png',
                                  errorBuilder: (context, error, stackTrace) {
                                    return CircleAvatar(
                                      backgroundColor: const Color(0xFF00B894)
                                          .withOpacity(0.2),
                                      child: Icon(
                                        Icons.person,
                                        color: const Color(0xFF00B894),
                                        size: isUser ? 20 : 18,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Add some bottom padding to replace the removed button
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.people,
                color: Color(0xFF94C1BA),
                size: 24,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(_onlinePlayers / 1000).toStringAsFixed(0)}k',
                    style: const TextStyle(
                      color: Color(0xFF94C1BA),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Online Players',
                    style: TextStyle(
                      color: Color(0xFF94C1BA),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 30.0, end: _timeRemaining.toDouble()),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: value <= 10
                          ? Colors.redAccent
                          : const Color(0xFF94C1BA),
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Seconds',
                    style: TextStyle(
                      color: Color(0xFF94C1BA),
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Stack(
      children: [
        Container(
          height: 4,
          color: Colors.grey.withOpacity(0.3),
          width: double.infinity,
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 4,
          color: const Color(0xFF94C1BA),
          width: MediaQuery.of(context).size.width *
              ((_currentQuestionIndex + 1) / _questions.length),
        ),
      ],
    );
  }

  Widget _buildQuestionSection(Map<String, dynamic> question) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: FadeTransition(
        opacity: _questionFadeAnimation,
        child: SlideTransition(
          position: _questionSlideAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question 0${_currentQuestionIndex + 1}',
                    style: const TextStyle(
                      color: Color(0xFF94C1BA),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      question['difficulty'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                question['question'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsSection(Map<String, dynamic> question) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: List.generate(
            4, // Always 4 options
            (index) => AnimatedBuilder(
              animation: _optionsAnimationController,
              builder: (context, child) {
                // Staggered animation for options
                final start = index * 0.1;
                final end = start + 0.4;
                final animationValue =
                    Interval(start, end, curve: Curves.easeOutQuad)
                        .transform(_optionsAnimationController.value);

                return Transform.translate(
                  offset: Offset(0, 50 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: _buildOptionItem(
                      index: index,
                      text: question['options'][index],
                      isSelected: _selectedAnswerIndex == index,
                      isCorrect: index == question['correctAnswer'],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required int index,
    required String text,
    required bool isSelected,
    required bool isCorrect,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF151918),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isCorrect
                    ? Colors.green.withOpacity(0.7)
                    : Colors.red.withOpacity(0.7))
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap:
                _selectedAnswerIndex == -1 ? () => _selectAnswer(index) : null,
            borderRadius: BorderRadius.circular(16),
            splashColor: const Color(0xFF94C1BA).withOpacity(0.1),
            highlightColor: const Color(0xFF94C1BA).withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Option ${(index + 1).toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          text,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? (isCorrect ? Colors.green : Colors.red)
                            : Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                      color: isSelected
                          ? (isCorrect
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2))
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCorrect ? Colors.green : Colors.red,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedOpacity(
        opacity: _selectedAnswerIndex != -1 ? 1.0 : 0.6,
        duration: const Duration(milliseconds: 300),
        child: ElevatedButton(
          onPressed: _selectedAnswerIndex != -1 ? _goToNextQuestion : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            minimumSize: const Size(double.infinity, 56),
            elevation: _selectedAnswerIndex != -1 ? 8 : 0,
            shadowColor: _selectedAnswerIndex != -1
                ? Colors.white.withOpacity(0.3)
                : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                color: Colors.black.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
