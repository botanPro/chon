import 'dart:async';
import 'dart:convert';

class FakeTriviaWebSocket {
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  // Simulate rooms: competitionId -> Set of playerIds
  final Map<String, Set<String>> _rooms = {};
  // Simulate leaderboard: competitionId -> Map<playerId, score>
  final Map<String, Map<String, int>> _leaderboards = {};

  // Questions per competition (for demo, all competitions use the same questions)
  final List<Map<String, dynamic>> _questions = [
    {
      'id': 'q1',
      'question': 'What is the capital of France?',
      'options': ['London', 'Berlin', 'Paris', 'Madrid'],
      'difficulty': 'Easy Level',
      'correctAnswer': 2,
    },
    {
      'id': 'q2',
      'question': 'Which planet is known as the Red Planet?',
      'options': ['Venus', 'Mars', 'Jupiter', 'Saturn'],
      'difficulty': 'Medium Level',
      'correctAnswer': 1,
    },
    {
      'id': 'q3',
      'question': 'Who wrote "Hamlet"?',
      'options': ['Shakespeare', 'Dickens', 'Austen', 'Orwell'],
      'difficulty': 'Difficult Level',
      'correctAnswer': 0,
    },
  ];

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void joinCompetition(String competitionId, String playerId) {
    _rooms.putIfAbsent(competitionId, () => <String>{}).add(playerId);
    _leaderboards.putIfAbsent(competitionId, () => <String, int>{});
    // Notify others in the room (simulate broadcast)
    _controller.add({
      'type': 'playerJoined',
      'competitionId': competitionId,
      'playerId': playerId,
      'timestamp': DateTime.now().toIso8601String(),
    });
    // Send the first question to the player
    sendQuestion(competitionId, 0);
  }

  void submitAnswer(
      String competitionId, String playerId, String questionId, int answer) {
    // Simulate scoring: +1 per correct answer
    final leaderboard = _leaderboards[competitionId]!;
    final question =
        _questions.firstWhere((q) => q['id'] == questionId, orElse: () => {});
    if (question.isNotEmpty && question['correctAnswer'] == answer) {
      leaderboard[playerId] = (leaderboard[playerId] ?? 0) + 1;
    }
    // Broadcast updated leaderboard
    final sortedLeaderboard = leaderboard.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    _controller.add({
      'type': 'leaderboardUpdate',
      'competitionId': competitionId,
      'leaderboard': [
        for (final entry in sortedLeaderboard)
          {'playerId': entry.key, 'score': entry.value}
      ],
    });
    // Send next question if available
    final currentIndex = _questions.indexWhere((q) => q['id'] == questionId);
    if (currentIndex != -1 && currentIndex + 1 < _questions.length) {
      sendQuestion(competitionId, currentIndex + 1);
    } else {
      // Game over event
      _controller.add({
        'type': 'gameOver',
        'competitionId': competitionId,
        'leaderboard': [
          for (final entry in sortedLeaderboard)
            {'playerId': entry.key, 'score': entry.value}
        ],
      });
    }
  }

  void sendQuestion(String competitionId, int questionIndex) {
    if (questionIndex < _questions.length) {
      _controller.add({
        'type': 'question',
        'competitionId': competitionId,
        'question': _questions[questionIndex],
      });
    }
  }

  void dispose() {
    _controller.close();
  }
}
