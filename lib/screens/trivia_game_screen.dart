import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/trivia_socket_service.dart';
import 'dart:convert';
import '../utils/apiConnection.dart';
import 'package:http/http.dart' as http;

class TriviaGameScreen extends StatefulWidget {
  final String competitionId;
  final String playerId;
  final String playerName;
  final Map<String, dynamic> competitionDetails;
  const TriviaGameScreen({
    Key? key,
    required this.competitionId,
    required this.playerId,
    required this.playerName,
    required this.competitionDetails,
  }) : super(key: key);

  @override
  State<TriviaGameScreen> createState() => _TriviaGameScreenState();
}

// Animated gradient background painter
class AnimatedGradientPainter extends CustomPainter {
  final double animationValue;
  final List<Color> colors;

  AnimatedGradientPainter({
    required this.animationValue,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create a rect for the entire canvas
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Create more dynamic gradient with animated positions and colors
    final gradient = LinearGradient(
      begin: Alignment(
        0.0,
        -0.5 + 0.3 * sin(animationValue * pi * 2),
      ),
      end: Alignment(
        0.2 * cos(animationValue * pi),
        1.0,
      ),
      colors: [
        colors[0],
        Color.lerp(
                colors[1], colors[2], sin(animationValue * pi) * 0.5 + 0.5) ??
            colors[1],
        Color.lerp(colors[2], colors[3],
                cos(animationValue * pi * 0.5) * 0.5 + 0.5) ??
            colors[2],
        colors[3],
      ],
      stops: [
        0.0,
        0.3 + 0.2 * sin(animationValue * pi * 2),
        0.6 + 0.2 * cos(animationValue * pi),
        1.0,
      ],
    );

    // Draw the gradient
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Add animated overlay pattern
    final patternPaint = Paint()
      ..color = Colors.white.withOpacity(0.015)
      ..strokeWidth = 0.6;

    // Draw animated grid pattern
    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      final offset = 10 * sin((i / size.width + animationValue * 2) * pi * 2);
      canvas.drawLine(
          Offset(i, 0), Offset(i + offset, size.height), patternPaint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      final offset = 10 * cos((i / size.height + animationValue * 2) * pi * 2);
      canvas.drawLine(
          Offset(0, i), Offset(size.width, i + offset), patternPaint);
    }

    // Add some subtle moving light spots
    final spotPaint = Paint()..color = Colors.white.withOpacity(0.02);

    for (int i = 0; i < 5; i++) {
      final x = size.width * (0.2 + 0.6 * sin(animationValue * pi + i * 1.2));
      final y =
          size.height * (0.2 + 0.6 * cos(animationValue * pi * 0.7 + i * 0.8));
      final radius = 50.0 + 30.0 * sin(animationValue * pi * 2 + i);

      canvas.drawCircle(
        Offset(x, y),
        radius,
        spotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedGradientPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

// Confetti particle class
class Confetti {
  double x;
  double y;
  double size;
  double velocity;
  double angle;
  double angularVelocity;
  Color color;

  Confetti({
    required this.x,
    required this.y,
    required this.size,
    required this.velocity,
    required this.angle,
    required this.angularVelocity,
    required this.color,
  });
}

// Painter for confetti effects
class ConfettiPainter extends CustomPainter {
  final List<Confetti> confetti;
  final double animationValue;

  ConfettiPainter({required this.animationValue})
      : confetti = _generateConfetti(80); // Fewer confetti particles

  static List<Confetti> _generateConfetti(int count) {
    final random = Random();
    final confetti = <Confetti>[];

    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
      const Color(0xFF94C1BA),
      Colors.white,
      Colors.red,
      Colors.blue,
    ];

    for (int i = 0; i < count; i++) {
      confetti.add(
        Confetti(
          x: random.nextDouble(),
          y: -0.2 - random.nextDouble() * 0.8, // Start above the screen
          size: 2 + random.nextDouble() * 3, // Smaller size
          velocity: 0.03 + random.nextDouble() * 0.06, // Much slower velocity
          angle: random.nextDouble() * pi * 2,
          angularVelocity:
              (random.nextDouble() - 0.5) * 0.05, // Slower rotation
          color: colors[random.nextInt(colors.length)],
        ),
      );
    }

    return confetti;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in confetti) {
      // Update position based on animation value - gentler movement
      final y = (particle.y + particle.velocity * animationValue) % 1.2;
      final x = particle.x + sin(y * 2) * 0.02; // Gentler horizontal movement

      // Draw confetti
      paint.color = particle.color;

      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(particle.angle + particle.angularVelocity * animationValue);

      // Draw rectangle confetti
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 2,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

// ---
// FLOW (matches HTML/Node backend):
// 1. User joins competition via REST (handled in home_screen.dart)
// 2. Connect to socket with JWT
// 3. Emit 'joinCompetition' with {competitionId, playerName}
// 4. Listen for:
//    - 'competitionData' (questions)
//    - 'leaderboardUpdate' (real-time)
//    - 'winners' (game over)
// 5. Emit:
//    - 'submitAnswer' ({competitionId, questionId, answer})
//    - 'finishGame' (competitionId)
// ---

class _TriviaGameScreenState extends State<TriviaGameScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _selectedAnswerIndex = -1;
  int _timeRemaining = 3;
  static const int _questionDuration = 3;
  int _correctAnswers = 0;
  late Timer _timer;
  bool _showGameOver = false;
  final int _onlinePlayers = 20000; // Dummy data

  // Pre-game countdown
  int _preGameCountdown = 0;
  Timer? _preGameTimer;
  bool _showPreGameCountdown = false;
  DateTime? _startTime;

  // Animation controllers
  late AnimationController _optionsAnimationController;
  late AnimationController _questionAnimationController;
  late AnimationController _gameOverAnimationController;
  late AnimationController _backgroundAnimationController;

  // Animations
  late Animation<double> _questionFadeAnimation;
  late Animation<Offset> _questionSlideAnimation;
  late Animation<double> _gameOverFadeAnimation;

  // Background gradient colors
  final List<Color> _gradientColors = [
    const Color(0xFF1c2221), // Teal 50 (darkest)
    const Color(0xFF323e3c), // Teal 100
    const Color(0xFF495d5a), // Teal 200
    const Color(0xFF1c2221).withOpacity(0.9), // Darker overlay
  ];

  // Leaderboard and player join events
  List<Map<String, dynamic>> _leaderboard = [];
  List<String> _playerJoins = [];

  List<Map<String, dynamic>> _questions = [];
  bool _loadingQuestions = true;

  // Socket service instance
  late TriviaSocketService _socketService;

  Map<String, dynamic>? _finalResults;
  bool _loadingResults = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkCompetitionStartTime();
  }

  void _checkCompetitionStartTime() {
    // Check if competition has started by checking the start time from competition details
    final startTime = widget.competitionDetails['start_time'];
    print('[DEBUG] Competition start time check: $startTime');

    if (startTime != null) {
      try {
        final startDateTime = DateTime.parse(startTime);
        final now = DateTime.now();
        final timeUntilStart = startDateTime.difference(now).inSeconds;

        print('[DEBUG] Start datetime: $startDateTime');
        print('[DEBUG] Current time: $now');
        print('[DEBUG] Time until start: $timeUntilStart seconds');

        if (timeUntilStart > 0) {
          // Competition hasn't started yet - show countdown and wait
          print(
              '[DEBUG] Competition has not started yet. Showing countdown for $timeUntilStart seconds');
          setState(() {
            _showPreGameCountdown = true;
            _preGameCountdown = timeUntilStart;
          });
          _startPreGameCountdown();
          return;
        } else {
          print('[DEBUG] Competition has already started or is starting now');
        }
      } catch (e) {
        print('Error parsing competition start time: $e');
        // If there's an error parsing the time, proceed as fallback
      }
    } else {
      print(
          '[DEBUG] No start time specified for competition - proceeding immediately');
    }

    // Competition has started or no start time specified - proceed with normal setup
    print('[DEBUG] Setting up socket connection for competition');
    _setupSocketConnection();
  }

  void _setupSocketConnection() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token ?? '';
    _socketService = TriviaSocketService();

    // Connect to socket with JWT token
    print('[DEBUG] Connecting to socket with token: $token');
    _socketService.connect('$socketUrl', token);

    // Validate joinCompetition payload
    final competitionIdRaw = widget.competitionId;
    final playerName = widget.playerName;

    final competitionId =
        (competitionIdRaw != null && competitionIdRaw.toString().isNotEmpty)
            ? (int.tryParse(competitionIdRaw) ?? competitionIdRaw)
            : null;

    print(
        '[DEBUG] joinCompetition payload: {competitionId: $competitionId (${competitionId.runtimeType}), playerName: $playerName (${playerName.runtimeType})}');

    if (competitionId == null || playerName == null || playerName.isEmpty) {
      print(
          '[DEBUG] Invalid joinCompetition payload: {competitionId: $competitionId, playerName: $playerName}');
      return;
    }

    _socketService.joinCompetition(
      competitionId.toString(),
      playerName: playerName,
    );

    // Set up event listeners
    _socketService.onLeaderboardUpdate((data) {
      print('[DEBUG] Received leaderboard event:');
      print(data);
      if (mounted && data is List && data.isNotEmpty) {
        setState(() {
          _leaderboard = List<Map<String, dynamic>>.from(data);
        });
      } else if (mounted) {
        setState(() {
          _leaderboard = [];
        });
      }
    });

    _socketService.onPlayerJoined((data) {
      print('[DEBUG] Player joined event:');
      print(data);
      if (mounted) {
        setState(() {
          _playerJoins.add(data['playerId'] ?? '');
        });
      }
    });

    _socketService.onWinners((data) {
      print('[DEBUG] Winners event:');
      print(data);
      if (mounted) {
        setState(() {
          _showGameOver = true;
          _leaderboard = List<Map<String, dynamic>>.from(data ?? []);
        });
        _gameOverAnimationController.forward();
        if (_timer.isActive) _timer.cancel();
      }
    });

    // Add answer submission confirmation listener
    _socketService.onAnswerSubmitted((data) {
      print('[DEBUG] Answer submitted confirmation event:');
      print(data);
      if (mounted) {
        // You can add UI feedback here if needed
      }
    });

    // Handle competition data (questions) from socket
    _socketService.onCompetitionData((data) {
      print('Competition data received: $data');
      List<Map<String, dynamic>> questions = [];
      if (data is Map<String, dynamic> && data['questions'] is List) {
        try {
          questions = List<Map<String, dynamic>>.from(data['questions']);
        } catch (e) {
          print('Error parsing questions: $e');
          questions = [];
        }
      } else {
        print('Invalid competition data format: $data');
      }

      setState(() {
        _questions = questions;
        _loadingQuestions = false;
        _currentQuestionIndex = 0;
        _selectedAnswerIndex = -1;
        _showGameOver = false;
        print('[DEBUG] _questions after setState: $_questions');
      });

      if (questions.isNotEmpty) {
        _questionAnimationController.forward();
        _optionsAnimationController.forward();
        _backgroundAnimationController.repeat();
        _timeRemaining = _questionDuration;
        _startTimer();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No questions available for this competition'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    });

    _socketService.onError((error) {
      print('Socket error in trivia game: $error');
      if (mounted) {
        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Connection error: ${error is Map ? error['message'] ?? 'Unknown error' : error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // Request competition data (questions) after a short delay to ensure connection
    Timer(const Duration(milliseconds: 500), () {
      if (mounted && _socketService.isConnected) {
        print(
            'Requesting competition data for  [38;5;28m${widget.competitionId} [0m');
        _socketService.getCompetitionData(widget.competitionId);
      }
    });

    // Retry getting competition data if not received within 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted && _loadingQuestions && _socketService.isConnected) {
        print(
            'Retrying competition data request for  [38;5;28m${widget.competitionId} [0m');
        _socketService.getCompetitionData(widget.competitionId);
      }
    });
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

    // Background animation controller - smooth continuous animation
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
  }

  void _handleWebSocketEvent(Map<String, dynamic> event) {
    final type = event['type'];
    if (type == 'question') {
      setState(() {
        if (_questions.isEmpty ||
            (_questions.isNotEmpty &&
                _questions.last['id'] != event['question']['id'])) {
          _questions.add(event['question'] as Map<String, dynamic>);
          _currentQuestionIndex = _questions.length - 1;
          _selectedAnswerIndex = -1;
          _timeRemaining = 3;
          _startTimer();
          _questionAnimationController.reset();
          _optionsAnimationController.reset();
          _questionAnimationController.forward();
          _optionsAnimationController.forward();
        }
      });
    } else if (type == 'leaderboardUpdate') {
      setState(() {
        _leaderboard =
            List<Map<String, dynamic>>.from(event['leaderboard'] ?? []);
      });
    } else if (type == 'playerJoined') {
      setState(() {
        _playerJoins.add(event['playerId'] ?? '');
      });
    } else if (type == 'gameOver') {
      setState(() {
        _showGameOver = true;
        _leaderboard =
            List<Map<String, dynamic>>.from(event['leaderboard'] ?? []);
      });
      _gameOverAnimationController.forward();
      _timer.cancel();
    }
  }

  @override
  void dispose() {
    // Clean up socket listeners and disconnect
    _socketService.disconnect();
    // Cancel timer if active
    if (_timer.isActive) _timer.cancel();
    // Dispose pre-game timer
    _preGameTimer?.cancel();
    // Dispose animation controllers
    _questionAnimationController.dispose();
    _optionsAnimationController.dispose();
    _gameOverAnimationController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _timer.cancel();
        // If not answered, submit -1 as answer
        if (_selectedAnswerIndex == -1 && _questions.isNotEmpty) {
          _submitAnswer(-1);
        }
        // Move to next question after timer ends
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          if (_currentQuestionIndex < _questions.length - 1) {
            setState(() {
              _currentQuestionIndex++;
              _selectedAnswerIndex = -1;
              _timeRemaining = _questionDuration;
            });
            _questionAnimationController.reset();
            _optionsAnimationController.reset();
            _questionAnimationController.forward();
            _optionsAnimationController.forward();
            _startTimer();
          } else {
            setState(() {
              _showGameOver = true;
            });
            _gameOverAnimationController.forward();
            _addGameResultToHistory();
            // Emit finishGame to get winners
            _socketService.finishGame(widget.competitionId);
          }
        });
      }
    });
  }

  void _goToNextQuestion() {
    // No longer needed: handled by WebSocket events
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
    if (_selectedAnswerIndex == -1 && _questions.isNotEmpty) {
      setState(() {
        _selectedAnswerIndex = index;
      });
      _submitAnswer(index);
      // Do NOT move to next question here; wait for timer to end
    }
  }

  void _submitAnswer(int answerIndex) {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      print('[DEBUG] No valid question to submit answer for.');
      return;
    }
    final question = _questions[_currentQuestionIndex];
    final options = question['options'] as List<dynamic>? ?? [];

    // Only submit if answerIndex is valid
    if (answerIndex < 0 || answerIndex >= options.length) {
      print('[DEBUG] Invalid answer index: $answerIndex');
      return;
    }

    final competitionId = int.tryParse(widget.competitionId);
    final questionId = (question['id'] is int)
        ? question['id'] as int
        : int.tryParse(question['id'].toString());
    final answer = answerIndex;

    if (competitionId == null || questionId == null) {
      print(
          '[DEBUG] Invalid competitionId or questionId for answer submission.');
      return;
    }

    final payload = {
      'competitionId': competitionId,
      'questionId': questionId,
      'answer': answer,
    };
    print('[DEBUG] Submitting answer payload: $payload');

    _socketService.submitAnswer(
      competitionId: competitionId,
      questionId: questionId,
      answer: answer,
    );

    int correctIndex = options.indexWhere(
        (opt) => (opt as Map<String, dynamic>)['is_correct'] == true);
    if (answerIndex == correctIndex) {
      _correctAnswers++;
    }
  }

  void _startPreGameCountdown() {
    print('[DEBUG] Starting pre-game countdown for $_preGameCountdown seconds');
    _preGameTimer?.cancel();
    _preGameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_preGameCountdown > 1) {
        setState(() {
          _preGameCountdown--;
        });
        if (_preGameCountdown % 10 == 0) {
          print(
              '[DEBUG] Pre-game countdown: $_preGameCountdown seconds remaining');
        }
      } else {
        timer.cancel();
        print(
            '[DEBUG] Pre-game countdown finished - competition is starting now!');
        setState(() {
          _showPreGameCountdown = false;
        });
        // Competition has started - now setup socket connection and start the game
        _setupSocketConnection();
      }
    });
  }

  void _showResultsAfterGame() async {
    setState(() {
      _loadingResults = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/api/competitions/${widget.competitionId}/results'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _finalResults = data['data'] ?? {};
          _loadingResults = false;
        });
      } else {
        setState(() {
          _loadingResults = false;
        });
        print('Failed to load results: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _loadingResults = false;
      });
      print('Error fetching results: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent back button/gesture during active game
      onWillPop: () async {
        // Allow back navigation only when game is over
        if (_showGameOver) {
          return true;
        }

        // Show confirmation dialog during active game
        final bool shouldPop = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A2322),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: const Color(0xFF96c3bc).withOpacity(0.2),
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
                  backgroundColor: const Color(0xFF96c3bc),
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
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E0D),
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: Stack(
          children: [
            if (_loadingQuestions)
              Center(child: CircularProgressIndicator())
            else if (_showGameOver)
              _buildWinnersScreen()
            else if (_questions.isEmpty)
              Center(child: Text('No questions found.'))
            else
              _buildGameScreen(),
            if (_showPreGameCountdown) _buildPreGameCountdownOverlay(),
            // Show competition info at the top
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // if (widget.competitionDetails['name'] != null)
                    //   Text(
                    //     widget.competitionDetails['name'],
                    //     style: const TextStyle(
                    //       color: Color(0xFF96c3bc),
                    //       fontSize: 22,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //     textAlign: TextAlign.center,
                    //   ),
                    // Removed description and entry fee display to avoid extra text in question area
                    // if (widget.competitionDetails['description'] != null)
                    //   Padding(
                    //     padding: const EdgeInsets.only(top: 4.0),
                    //     child: Text(
                    //       widget.competitionDetails['description'],
                    //       style: const TextStyle(
                    //         color: Colors.white70,
                    //         fontSize: 14,
                    //       ),
                    //       textAlign: TextAlign.center,
                    //     ),
                    //   ),
                    // if (widget.competitionDetails['entry_fee'] != null)
                    //   Padding(
                    //     padding: const EdgeInsets.only(top: 2.0),
                    //     child: Text(
                    //       'Entry Fee: \\$${widget.competitionDetails['entry_fee']}',
                    //       style: const TextStyle(
                    //         color: Color(0xFF96c3bc),
                    //         fontSize: 13,
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    print('[DEBUG] _questions in _buildGameScreen: $_questions');
    print('[DEBUG] _currentQuestionIndex: $_currentQuestionIndex');
    if (_loadingQuestions) {
      return Center(child: CircularProgressIndicator());
    }
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      print(
          '[DEBUG] No questions found or index out of range, showing leaderboard.');
      return Center(child: Text('No questions found.'));
    }
    final question = _questions[_currentQuestionIndex];

    return Stack(
      fit: StackFit.expand,
      children: [
        // Animated gradient background
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return CustomPaint(
                painter: AnimatedGradientPainter(
                  animationValue: _backgroundAnimationController.value,
                  colors: _gradientColors,
                ),
              );
            },
          ),
        ),

        // Main content
        SafeArea(
          bottom: false, // Extend to the bottom edge
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressBar(),
              _buildQuestionSection(question),
              _buildOptionsSection(question),
              if (_selectedAnswerIndex != -1) _buildWaitingIndicator(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWinnersScreen() {
    // Use leaderboard from results API if available
    final List<dynamic> leaderboardResults =
        _finalResults != null && _finalResults!['leaderboard'] is List
            ? _finalResults!['leaderboard']
            : _leaderboard.take(10).toList();

    // Call results API if not already loaded
    if (_finalResults == null && !_loadingResults) {
      _showResultsAfterGame();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Animated gradient background
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return CustomPaint(
                painter: AnimatedGradientPainter(
                  animationValue: _backgroundAnimationController.value,
                  colors: _gradientColors,
                ),
              );
            },
          ),
        ),

        // Main content
        SafeArea(
          bottom: false, // Extend to the bottom edge
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1E2928).withOpacity(0.9),
                        const Color(0xFF151918).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF96c3bc).withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF96c3bc).withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Game Over',
                        style: TextStyle(
                          color: Color(0xFF96c3bc),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Score: ${_correctAnswers}/${_questions.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_loadingResults)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: CircularProgressIndicator(
                              color: Color(0xFF96c3bc)),
                        )
                      else if (_finalResults != null)
                        Column(
                          children: [
                            if (_finalResults!['playerResult'] != null) ...[
                              Text(
                                'Final Rank: ${_finalResults!['playerResult']['rank'] ?? '--'}',
                                style: const TextStyle(
                                  color: Color(0xFF96c3bc),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Final Score: ${_finalResults!['playerResult']['score'] ?? '--'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              if (_finalResults!['playerResult']['prize'] !=
                                  null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Prize: ${_finalResults!['playerResult']['prize']['type'] == 'cash' ? '\$' + _finalResults!['playerResult']['prize']['value'].toString() : _finalResults!['playerResult']['prize']['details']}',
                                    style: const TextStyle(
                                      color: Color(0xFF94C1BA),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      Text(
                        'Top Players',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Players list (from results API if available)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: leaderboardResults.length,
                  itemBuilder: (context, index) {
                    final player = leaderboardResults[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF151918).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF96c3bc).withOpacity(0.1),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Color(0xFF96c3bc),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              (player['nickname'] as String?) ??
                                  player['player_name'] ??
                                  'Unknown',
                              style: TextStyle(
                                color: player['playerId'] == widget.playerId ||
                                        player['player_id']?.toString() ==
                                            widget.playerId
                                    ? Color(0xFF96c3bc)
                                    : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (player['score'] != null)
                            Text(
                              '${player['score']} pts',
                              style: const TextStyle(
                                color: Color(0xFF96c3bc),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (player['prize'] != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                player['prize']['type'] == 'cash'
                                    ? '\$' + player['prize']['value'].toString()
                                    : player['prize']['details'] ?? '',
                                style: const TextStyle(
                                  color: Color(0xFF94C1BA),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Back to Home button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: ElevatedButton(
                  onPressed: () {
                    // Completely reset all game state and socket connection
                    if (_timer.isActive) {
                      _timer.cancel();
                    }
                    _socketService.disconnect();
                    setState(() {
                      _questions = [];
                      _leaderboard = [];
                      _currentQuestionIndex = 0;
                      _selectedAnswerIndex = -1;
                      _timeRemaining = 3;
                      _correctAnswers = 0;
                      _showGameOver = false;
                      _playerJoins = [];
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF96c3bc),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(double.infinity, 56),
                    elevation: 4,
                    shadowColor: const Color(0xFF96c3bc).withOpacity(0.4),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A2322).withOpacity(0.8),
            const Color(0xFF0F1514).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF96c3bc).withOpacity(0.1),
                ),
                child: Icon(
                  Icons.people,
                  color: const Color(0xFF96c3bc),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(_onlinePlayers / 1000).toStringAsFixed(0)}k',
                    style: const TextStyle(
                      color: Color(0xFF96c3bc),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Online Players',
                    style: TextStyle(
                      color: Color(0xFF96c3bc),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _timeRemaining <= 2
                      ? Colors.redAccent.withOpacity(0.2)
                      : const Color(0xFF96c3bc).withOpacity(0.2),
                  _timeRemaining <= 2
                      ? Colors.redAccent.withOpacity(0.05)
                      : const Color(0xFF96c3bc).withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: _timeRemaining <= 2
                    ? Colors.redAccent.withOpacity(0.3)
                    : const Color(0xFF96c3bc).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 5.0, end: _timeRemaining.toDouble()),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color:
                        value <= 2 ? Colors.redAccent : const Color(0xFF96c3bc),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF96c3bc).withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Progress
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 8,
            width: MediaQuery.of(context).size.width *
                    ((_currentQuestionIndex + 1) / _questions.length) -
                32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF96c3bc),
                  const Color(0xFF7b9f9a),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF96c3bc).withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: -1,
                ),
              ],
            ),
          ),

          // Dots for each question
          SizedBox(
            height: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                _questions.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index <= _currentQuestionIndex
                        ? Colors.white
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(Map<String, dynamic> question) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: FadeTransition(
        opacity: _questionFadeAnimation,
        child: SlideTransition(
          position: _questionSlideAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E2928).withOpacity(0.9),
                  const Color(0xFF151918).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF96c3bc).withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
              border: Border.all(
                color: const Color(0xFF96c3bc).withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF96c3bc).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Question 0${_currentQuestionIndex + 1}',
                        style: const TextStyle(
                          color: Color(0xFF96c3bc),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Colors.white.withOpacity(0.7),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (question['question_type'] as String?) ??
                                'multi_choice',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  (question['question_text'] as String?) ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: _timeRemaining / 3, // 3 seconds total
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _timeRemaining <= 2
                        ? Colors.redAccent
                        : const Color(0xFF96c3bc),
                  ),
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsSection(Map<String, dynamic> question) {
    final options = question['options'] as List<dynamic>? ?? [];

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final isSelected = _selectedAnswerIndex == index;
            final optionMap = options[index] as Map<String, dynamic>? ?? {};
            final optionText = optionMap['option'] as String? ?? '';

            // Staggered animation for options
            return AnimatedBuilder(
              animation: _optionsAnimationController,
              builder: (context, child) {
                final start = index * 0.1;
                final end = start + 0.4;
                final animationValue = Interval(
                  start,
                  end,
                  curve: Curves.easeOutQuad,
                ).transform(_optionsAnimationController.value);

                return Transform.translate(
                  offset: Offset(0, 30 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity:
                          _selectedAnswerIndex == -1 || isSelected ? 1.0 : 0.5,
                      child: _buildOptionItem(
                        index: index,
                        text: optionText,
                        isSelected: isSelected,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required int index,
    required String text,
    required bool isSelected,
  }) {
    // Define colors based on selection state
    final Color bgColor = isSelected
        ? const Color(0xFF96c3bc).withOpacity(0.15)
        : const Color(0xFF151918);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF96c3bc).withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF96c3bc).withOpacity(0.2)
                  : Colors.black.withOpacity(0.2),
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
            splashColor: const Color(0xFF96c3bc).withOpacity(0.1),
            highlightColor: const Color(0xFF96c3bc).withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF96c3bc).withOpacity(0.1),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index), // A, B, C, D
                                  style: const TextStyle(
                                    color: Color(0xFF96c3bc),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF96c3bc),
                          width: 2,
                        ),
                        color: const Color(0xFF96c3bc).withOpacity(0.1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check,
                          color: Color(0xFF96c3bc),
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingIndicator() {
    return AnimatedOpacity(
      opacity: _selectedAnswerIndex != -1 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A2322).withOpacity(0.8),
              const Color(0xFF0F1514).withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF96c3bc).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF96c3bc).withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: -5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF96c3bc),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Waiting for next question',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Next question in ${_timeRemaining.toInt()} seconds',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreGameCountdownOverlay() {
    final minutes = _preGameCountdown ~/ 60;
    final seconds = _preGameCountdown % 60;

    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Competition starts in',
              style: TextStyle(
                color: Color(0xFF96c3bc),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 80,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please wait...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
