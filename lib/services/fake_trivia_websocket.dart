import 'dart:async';
import 'dart:convert';

class FakeTriviaWebSocket {
  final _controller = StreamController<String>();
  int _questionIndex = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the capital of France?',
      'options': ['London', 'Berlin', 'Paris', 'Madrid'],
      'difficulty': 'Easy Level',
      'correctAnswer': 2,
    },
    {
      'question': 'Which planet is known as the Red Planet?',
      'options': ['Venus', 'Mars', 'Jupiter', 'Saturn'],
      'difficulty': 'Medium Level',
      'correctAnswer': 1,
    },
    {
      'question': 'Who wrote "Hamlet"?',
      'options': ['Shakespeare', 'Dickens', 'Austen', 'Orwell'],
      'difficulty': 'Difficult Level',
      'correctAnswer': 0,
    },
  ];

  Stream<String> get stream => _controller.stream;

  void start() {
    for (final q in _questions) {
      _controller.add(jsonEncode(q));
    }
    _controller.close();
  }

  void dispose() {
    _controller.close();
  }
}
