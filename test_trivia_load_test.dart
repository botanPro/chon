import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Load test configuration - matches the user's API connection
class LoadTestConfig {
  static const int totalUsers = 100;
  static const int rampUpTimeSeconds = 30; // Time to start all users
  static const int testDurationSeconds = 300; // 5 minutes test
  static const String serverUrl =
      'http://localhost:3000'; // Matches apiConnection.dart
  static const String apiBaseUrl =
      'http://localhost:3000'; // Matches apiConnection.dart
}

/// Represents a test user - matches the trivia game screen behavior
class TestUser {
  final String id;
  final String name;
  late IO.Socket socket;
  bool isConnected = false;
  bool hasJoinedCompetition = false;
  int correctAnswers = 0;
  int totalQuestions = 0;
  DateTime? joinTime;
  DateTime? firstAnswerTime;
  DateTime? lastAnswerTime;
  List<Map<String, dynamic>> answers = [];
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  int selectedAnswerIndex = -1;
  int timeRemaining = 3;
  bool showGameOver = false;
  final Random random = Random();

  TestUser(this.id) : name = 'TestUser_$id';

  /// Connect to the socket server - matches trivia_socket_service.dart
  Future<void> connect() async {
    try {
      socket = IO.io(
        LoadTestConfig.serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );

      socket.onConnect((_) {
        isConnected = true;
        joinTime = DateTime.now();
        print('User $name connected');
      });

      socket.onDisconnect((_) {
        isConnected = false;
        print('User $name disconnected');
      });

      socket.onConnectError((error) {
        print('User $name connection error: $error');
      });

      socket.onError((err) {
        print('User $name general error: $err');
      });

      socket.connect();

      // Wait for connection
      await Future.delayed(Duration(milliseconds: 500 + random.nextInt(1000)));
    } catch (e) {
      print('Error connecting user $name: $e');
    }
  }

  /// Join a competition - matches trivia_socket_service.dart
  void joinCompetition(String competitionId) {
    if (!isConnected) return;

    socket.emit('joinCompetition', {
      'competitionId': competitionId,
      'playerId': id,
      'playerName': name,
    });

    hasJoinedCompetition = true;
    print('User $name joined competition $competitionId');
  }

  /// Submit an answer - matches trivia_socket_service.dart
  void submitAnswer({
    required String competitionId,
    required String questionId,
    required String answer,
  }) {
    if (!isConnected || !hasJoinedCompetition) return;

    socket.emit('submitAnswer', {
      'competitionId': competitionId,
      'playerId': id,
      'questionId': questionId,
      'answer': answer,
    });

    final answerData = {
      'questionId': questionId,
      'answer': answer,
      'timestamp': DateTime.now().toIso8601String(),
    };
    answers.add(answerData);

    if (firstAnswerTime == null) {
      firstAnswerTime = DateTime.now();
    }
    lastAnswerTime = DateTime.now();

    print('User $name submitted answer: $answer for question $questionId');
  }

  /// Simulate answering a question - matches trivia_game_screen.dart behavior
  void simulateAnswer(String questionId, List<String> options) {
    if (!isConnected || !hasJoinedCompetition) return;

    // Simulate different user behaviors like in the game
    String answer;
    final behavior = random.nextInt(100);

    if (behavior < 70) {
      // 70% chance of random answer
      answer = random.nextInt(options.length).toString();
    } else if (behavior < 85) {
      // 15% chance of always choosing first option
      answer = '0';
    } else if (behavior < 95) {
      // 10% chance of always choosing last option
      answer = (options.length - 1).toString();
    } else {
      // 5% chance of intelligent answer (simulate correct answer)
      answer = '0'; // Assume first option is often correct
    }

    submitAnswer(
      competitionId: TriviaLoadTest.selectedCompetitionId,
      questionId: questionId,
      answer: answer,
    );
  }

  /// Get competition data - matches trivia_socket_service.dart
  void getCompetitionData(String competitionId) {
    if (socket.connected) {
      print('User $name requesting competition data for $competitionId');
      socket.emit('getCompetitionData', competitionId);
    } else {
      print('User $name socket not connected, cannot emit getCompetitionData');
    }
  }

  /// Disconnect the user
  void disconnect() {
    if (isConnected) {
      socket.disconnect();
      isConnected = false;
    }
  }

  /// Get user statistics
  Map<String, dynamic> getStats() {
    return {
      'userId': id,
      'userName': name,
      'isConnected': isConnected,
      'hasJoinedCompetition': hasJoinedCompetition,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'accuracy': totalQuestions > 0
          ? (correctAnswers / totalQuestions * 100).toStringAsFixed(2)
          : '0.00',
      'joinTime': joinTime?.toIso8601String(),
      'firstAnswerTime': firstAnswerTime?.toIso8601String(),
      'lastAnswerTime': lastAnswerTime?.toIso8601String(),
      'totalAnswers': answers.length,
      'responseTime': firstAnswerTime != null && joinTime != null
          ? firstAnswerTime!.difference(joinTime!).inMilliseconds
          : null,
    };
  }
}

/// Load test orchestrator
class TriviaLoadTest {
  static String selectedCompetitionId = '';
  final List<TestUser> users = [];
  final List<Map<String, dynamic>> testResults = [];
  final Stopwatch testTimer = Stopwatch();
  Timer? testTimerInterval;
  Timer? rampUpTimer;
  int activeUsers = 0;
  int totalQuestionsReceived = 0;
  int totalAnswersSubmitted = 0;
  final Random random = Random();

  /// Fetch available competitions from the backend
  Future<List<Map<String, dynamic>>> fetchCompetitions() async {
    try {
      print('🔍 Fetching available competitions...');
      final response = await http.get(
        Uri.parse('${LoadTestConfig.apiBaseUrl}/api/competitions'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final competitions =
            List<Map<String, dynamic>>.from(data['competitions'] ?? []);
        print('✅ Found ${competitions.length} competitions');
        return competitions;
      } else {
        print('❌ Failed to fetch competitions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching competitions: $e');
      return [];
    }
  }

  /// Select a competition for testing
  Future<String?> selectCompetition() async {
    final competitions = await fetchCompetitions();

    if (competitions.isEmpty) {
      print(
          '⚠️  No competitions found via API, using default competition ID: 1');
      return '1'; // Use the known competition ID
    }

    // Select the first available competition
    final selectedCompetition = competitions.first;
    final competitionId = selectedCompetition['id']?.toString() ?? '';

    if (competitionId.isEmpty) {
      print('❌ Invalid competition ID');
      return null;
    }

    print(
        '🎯 Selected competition: ${selectedCompetition['name'] ?? 'Unknown'} (ID: $competitionId)');
    return competitionId;
  }

  /// Start the load test
  Future<void> startTest() async {
    print('🚀 Starting Trivia Load Test');
    print('📊 Configuration:');
    print('   - Total Users: ${LoadTestConfig.totalUsers}');
    print('   - Ramp Up Time: ${LoadTestConfig.rampUpTimeSeconds}s');
    print('   - Test Duration: ${LoadTestConfig.testDurationSeconds}s');
    print('   - Server URL: ${LoadTestConfig.serverUrl}');
    print('');

    // First, get a real competition ID
    final competitionId = await selectCompetition();
    if (competitionId == null) {
      print('❌ Cannot proceed without a valid competition');
      return;
    }

    selectedCompetitionId = competitionId;

    // Create test users
    for (int i = 1; i <= LoadTestConfig.totalUsers; i++) {
      users.add(TestUser(i.toString().padLeft(3, '0')));
    }

    // Start test timer
    testTimer.start();
    testTimerInterval = Timer.periodic(const Duration(seconds: 10), (timer) {
      _printTestStatus();
    });

    // Ramp up users gradually
    await _rampUpUsers();

    // Run test for specified duration
    await Future.delayed(Duration(seconds: LoadTestConfig.testDurationSeconds));

    // Clean up
    await _cleanup();

    // Generate report
    _generateReport();
  }

  /// Gradually start users - matches trivia_game_screen.dart initialization
  Future<void> _rampUpUsers() async {
    final usersPerSecond =
        LoadTestConfig.totalUsers / LoadTestConfig.rampUpTimeSeconds;
    int startedUsers = 0;

    rampUpTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final usersToStart =
          (usersPerSecond * (timer.tick)).round() - startedUsers;

      for (int i = 0;
          i < usersToStart && startedUsers < LoadTestConfig.totalUsers;
          i++) {
        final user = users[startedUsers];
        await user.connect();

        // Set up event listeners like in trivia_game_screen.dart
        _setupUserEventListeners(user);

        // Join competition after a short delay
        Timer(Duration(milliseconds: 500 + random.nextInt(2000)), () {
          user.joinCompetition(selectedCompetitionId);
          user.getCompetitionData(selectedCompetitionId);
        });

        startedUsers++;
        activeUsers++;
      }

      if (startedUsers >= LoadTestConfig.totalUsers) {
        timer.cancel();
        print('✅ All users started');
      }
    });
  }

  /// Set up event listeners - matches trivia_game_screen.dart event handling
  void _setupUserEventListeners(TestUser user) {
    // Listen for competition data - matches trivia_game_screen.dart
    user.socket.on('competitionData', (data) {
      totalQuestionsReceived++;
      final questions = data['questions'] as List<dynamic>? ?? [];
      if (questions.isNotEmpty) {
        user.questions = List<Map<String, dynamic>>.from(questions);
        user.currentQuestionIndex = 0;
        user.selectedAnswerIndex = -1;
        user.timeRemaining = 3;
        user.showGameOver = false;
        user.correctAnswers = 0;
        print('User ${user.name} received ${questions.length} questions');
      }
    });

    // Listen for questions - matches trivia_game_screen.dart
    user.socket.on('question', (data) {
      totalQuestionsReceived++;
      final question = data as Map<String, dynamic>;
      final questionId = question['id']?.toString() ?? '';
      final options = (question['options'] as List<dynamic>? ?? [])
          .map((opt) =>
              (opt as Map<String, dynamic>)['option']?.toString() ?? '')
          .toList();

      // Simulate answer after random delay (1-3 seconds) like real users
      Timer(Duration(milliseconds: 1000 + random.nextInt(2000)), () {
        user.simulateAnswer(questionId, options);
        totalAnswersSubmitted++;
      });
    });

    // Listen for leaderboard updates - matches trivia_game_screen.dart
    user.socket.on('leaderboardUpdate', (data) {
      // Track leaderboard updates if needed
      print('User ${user.name} received leaderboard update');
    });

    // Listen for player joined events - matches trivia_game_screen.dart
    user.socket.on('playerJoined', (data) {
      print('User ${user.name} received player joined event');
    });

    // Listen for winners event - matches trivia_game_screen.dart
    user.socket.on('winners', (data) {
      print('User ${user.name} received winners event');
    });
  }

  /// Print current test status
  void _printTestStatus() {
    final elapsed = testTimer.elapsed.inSeconds;
    final connectedUsers = users.where((u) => u.isConnected).length;
    final joinedUsers = users.where((u) => u.hasJoinedCompetition).length;

    print('⏱️  Test Status (${elapsed}s elapsed):');
    print('   - Connected Users: $connectedUsers/${LoadTestConfig.totalUsers}');
    print('   - Joined Competition: $joinedUsers');
    print('   - Questions Received: $totalQuestionsReceived');
    print('   - Answers Submitted: $totalAnswersSubmitted');
    print('');
  }

  /// Clean up resources
  Future<void> _cleanup() async {
    print('🧹 Cleaning up...');

    testTimerInterval?.cancel();
    rampUpTimer?.cancel();

    // Disconnect all users
    for (final user in users) {
      user.disconnect();
    }

    // Wait for disconnections
    await Future.delayed(const Duration(seconds: 2));

    testTimer.stop();
    print('✅ Cleanup completed');
  }

  /// Generate test report
  void _generateReport() {
    final testDuration = testTimer.elapsed;
    final connectedUsers = users.where((u) => u.isConnected).length;
    final joinedUsers = users.where((u) => u.hasJoinedCompetition).length;
    final totalAnswers =
        users.fold<int>(0, (sum, user) => sum + user.answers.length);

    print('');
    print('📊 LOAD TEST REPORT');
    print('==================');
    print('Test Duration: ${testDuration.inSeconds}s');
    print('Total Users: ${LoadTestConfig.totalUsers}');
    print('Connected Users: $connectedUsers');
    print('Joined Competition: $joinedUsers');
    print('Questions Received: $totalQuestionsReceived');
    print('Answers Submitted: $totalAnswersSubmitted');
    print('');

    // Calculate averages
    if (joinedUsers > 0) {
      final avgQuestionsPerUser = totalQuestionsReceived / joinedUsers;
      final avgAnswersPerUser = totalAnswers / joinedUsers;

      print('📈 Averages:');
      print(
          '   - Questions per User: ${avgQuestionsPerUser.toStringAsFixed(2)}');
      print('   - Answers per User: ${avgAnswersPerUser.toStringAsFixed(2)}');
      print('');
    }

    // User statistics
    print('👥 User Statistics:');
    final userStats = users.map((u) => u.getStats()).toList();

    // Sort by accuracy
    userStats.sort((a, b) {
      final aAccuracy = double.tryParse(a['accuracy'] ?? '0') ?? 0;
      final bAccuracy = double.tryParse(b['accuracy'] ?? '0') ?? 0;
      return bAccuracy.compareTo(aAccuracy);
    });

    // Show top 10 users
    print('Top 10 Users by Accuracy:');
    for (int i = 0; i < 10 && i < userStats.length; i++) {
      final stats = userStats[i];
      print(
          '   ${i + 1}. ${stats['userName']}: ${stats['accuracy']}% (${stats['correctAnswers']}/${stats['totalQuestions']})');
    }

    // Save detailed results to file
    _saveResultsToFile(userStats, testDuration);
  }

  /// Save detailed results to file
  void _saveResultsToFile(
      List<Map<String, dynamic>> userStats, Duration testDuration) {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final filename = 'trivia_load_test_results_$timestamp.json';

    final results = {
      'testConfig': {
        'totalUsers': LoadTestConfig.totalUsers,
        'rampUpTimeSeconds': LoadTestConfig.rampUpTimeSeconds,
        'testDurationSeconds': LoadTestConfig.testDurationSeconds,
        'serverUrl': LoadTestConfig.serverUrl,
        'competitionId': selectedCompetitionId,
      },
      'testResults': {
        'duration': testDuration.inSeconds,
        'totalQuestionsReceived': totalQuestionsReceived,
        'totalAnswersSubmitted': totalAnswersSubmitted,
        'connectedUsers': users.where((u) => u.isConnected).length,
        'joinedUsers': users.where((u) => u.hasJoinedCompetition).length,
      },
      'userStats': userStats,
    };

    try {
      File(filename).writeAsStringSync(jsonEncode(results));
      print('💾 Detailed results saved to: $filename');
    } catch (e) {
      print('❌ Error saving results: $e');
    }
  }
}

/// Main function to run the load test
Future<void> main() async {
  print('🎮 Trivia Game Load Test Tool');
  print('============================');
  print('This test will simulate 100 users playing your trivia game');
  print(
      'Make sure your backend server is running on: ${LoadTestConfig.serverUrl}');
  print('');

  // Check if server is reachable
  try {
    final response = await http
        .get(Uri.parse('${LoadTestConfig.apiBaseUrl}/health'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      print('⚠️  Warning: Server health check failed (${response.statusCode})');
    } else {
      print('✅ Server is reachable');
    }
  } catch (e) {
    print('⚠️  Warning: Cannot reach server at ${LoadTestConfig.apiBaseUrl}');
    print(
        '   Make sure your trivia server is running before starting the test');
    print('');
  }

  // Confirm before starting
  print('Press Enter to start the load test...');
  await stdin.readLineSync();

  final loadTest = TriviaLoadTest();
  await loadTest.startTest();
}
