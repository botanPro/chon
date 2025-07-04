import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

/// Service for managing trivia game socket connection and events.
class TriviaSocketService {
  static final TriviaSocketService _instance = TriviaSocketService._internal();
  factory TriviaSocketService() => _instance;

  late IO.Socket socket;
  bool _isConnected = false;
  final Map<String, dynamic Function(dynamic)> _listeners = {};

  TriviaSocketService._internal();

  /// Connects to the socket server with JWT authentication.
  void connect(String url, String jwtToken) {
    if (_isConnected) return;
    print('Connecting to $url with JWT token');
    socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': jwtToken})
          .build(),
    );
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
    });
    socket.onError((err) {
      print('Socket general error: $err');
    });
  }

  /// Joins a competition room.
  void joinCompetition(String competitionId,
      {required String playerId, required String playerName}) {
    socket.emit('joinCompetition', {
      'competitionId': competitionId,
      'playerId': playerId,
      'playerName': playerName,
    });
  }

  /// Submits an answer for a question.
  void submitAnswer({
    required String competitionId,
    required String playerId,
    required String questionId,
    required String answer,
  }) {
    socket.emit('submitAnswer', {
      'competitionId': competitionId,
      'playerId': playerId,
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

  /// Registers a competition data listener.
  void onCompetitionData(Function(dynamic) callback) {
    print('Registering competitionData listener');
    _removeListener('competitionData');
    _addListener('competitionData', callback);
  }

  /// Requests competition data from the server.
  void getCompetitionData(String competitionId) {
    if (socket.connected) {
      print('Emitting getCompetitionData for $competitionId');
      socket.emit('getCompetitionData', competitionId);
    } else {
      print('Socket not connected, cannot emit getCompetitionData');
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
