import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

/// Service for managing trivia game socket connection and events.
///
/// FLOW:
/// 1. Connect to socket with JWT (same as HTML)
/// 2. Emit 'joinCompetition' with {competitionId, playerName}
/// 3. Listen for:
///    - 'competitionData' (questions)
///    - 'leaderboardUpdate' (real-time leaderboard)
///    - 'winners' (game over)
/// 4. Emit:
///    - 'submitAnswer' ({competitionId, questionId, answer})
///    - 'finishGame' (competitionId)
///
/// All payloads and event names match the backend/HTML flow.
class TriviaSocketService {
  static final TriviaSocketService _instance = TriviaSocketService._internal();
  factory TriviaSocketService() => _instance;

  late IO.Socket socket;
  bool _isConnected = false;
  final Map<String, dynamic Function(dynamic)> _listeners = {};

  TriviaSocketService._internal();

  /// Checks if the socket is currently connected.
  bool get isConnected => _isConnected && socket.connected;

  /// Connects to the socket server with JWT authentication.
  void connect(String url, String jwtToken) {
    if (_isConnected) return;
    if (jwtToken == null || jwtToken.isEmpty) {
      print('[ERROR] Tried to connect socket without a valid JWT token!');
      return;
    }
    print('Connecting to $url with JWT token: "' + jwtToken.toString() + '"');

    // Convert HTTP URL to WebSocket URL if needed
    String wsUrl = url;
    if (url.startsWith('http://')) {
      wsUrl = url.replaceFirst('http://', 'ws://');
    } else if (url.startsWith('https://')) {
      wsUrl = url.replaceFirst('https://', 'wss://');
    }

    print('Using WebSocket URL: $wsUrl');

    socket = IO.io(
      wsUrl,
      IO.OptionBuilder().setTransports(['websocket', 'polling']).setAuth({
        'token': jwtToken
      }).setExtraHeaders({'Authorization': 'Bearer $jwtToken'}).build(),
    );
    print('Socket extra headers: Authorization: Bearer $jwtToken');
    socket.connect();
    socket.onConnect((_) {
      print('Socket connected!');
      _isConnected = true;
    });
    socket.onDisconnect((_) {
      print('Socket disconnected!');
      _isConnected = false;
    });
    socket.onConnectError((err) {
      print('Socket connection error: $err');
      _isConnected = false;
    });
    socket.onError((err) {
      print('Socket general error: $err');
      _isConnected = false;
    });

    // Listen for authentication errors
    socket.on('error', (error) {
      print('Socket authentication error: $error');
      if (error is Map && error['message'] != null) {
        print('Error message: ${error['message']}');
      }
    });
  }

  /// Joins a competition room. (matches HTML/Node backend)
  void joinCompetition(String competitionId, {required String playerName}) {
    socket.emit('joinCompetition', {
      'competitionId': competitionId,
      'playerName': playerName,
    });
  }

  /// Submits an answer for a question. (matches HTML/Node backend)
  void submitAnswer({
    required int competitionId,
    required int questionId,
    required int answer,
  }) {
    // Send only the fields expected by the backend (no playerId)
    socket.emit('submitAnswer', {
      'competitionId': competitionId,
      'questionId': questionId,
      'answer': answer,
    });
  }

  /// Registers a leaderboard update listener.
  void onLeaderboardUpdate(Function(dynamic) callback) {
    _addListener('leaderboardUpdate', callback);
  }

  /// Registers a player joined listener.
  void onPlayerJoined(Function(dynamic) callback) {
    _addListener('playerJoined', callback);
  }

  /// Registers a competition data listener (questions).
  void onCompetitionData(Function(dynamic) callback) {
    print('Registering competitionData listener');
    _removeListener('competitionData');
    _addListener('competitionData', callback);
  }

  /// Registers a winners listener (game over).
  void onWinners(Function(dynamic) callback) {
    _addListener('winners', callback);
  }

  /// Registers an answer submitted confirmation listener.
  void onAnswerSubmitted(Function(dynamic) callback) {
    _addListener('answerSubmitted', callback);
  }

  /// Registers an error listener.
  void onError(Function(dynamic) callback) {
    _addListener('error', callback);
  }

  /// Requests competition data from the server (questions).
  void getCompetitionData(String competitionId) {
    if (isConnected) {
      print('Emitting getCompetitionData for $competitionId');
      socket.emit('getCompetitionData', competitionId);
    } else {
      print('Socket not connected, cannot emit getCompetitionData');
    }
  }

  /// Finishes the game and requests winners.
  void finishGame(String competitionId) {
    if (isConnected) {
      print('Emitting finishGame for $competitionId');
      socket.emit('finishGame', competitionId);
    } else {
      print('Socket not connected, cannot emit finishGame');
    }
  }

  /// Disconnects the socket and removes all listeners.
  void disconnect() {
    if (_isConnected) {
      _removeAllListeners();
      socket.disconnect();
      _isConnected = false;
    }
  }

  /// Adds a socket event listener and tracks it for cleanup.
  void _addListener(String event, dynamic Function(dynamic) callback) {
    _removeListener(event);
    socket.on(event, callback);
    _listeners[event] = callback;
  }

  /// Removes a specific socket event listener.
  void _removeListener(String event) {
    if (_listeners.containsKey(event)) {
      socket.off(event, _listeners[event]);
      _listeners.remove(event);
    }
  }

  /// Removes all registered socket event listeners.
  void _removeAllListeners() {
    _listeners.forEach((event, callback) {
      socket.off(event, callback);
    });
    _listeners.clear();
  }
}
