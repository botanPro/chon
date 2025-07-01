import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

class TriviaSocketService {
  static final TriviaSocketService _instance = TriviaSocketService._internal();
  factory TriviaSocketService() => _instance;

  late IO.Socket socket;

  TriviaSocketService._internal();

  void connect(String url) {
    print('Connecting to $url');
    socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
    socket.connect();
    socket.onConnect((_) {
      print('Socket connected!');
    });
    socket.onConnectError((err) {
      print('Socket connection error: $err');
    });
    socket.onError((err) {
      print('Socket general error: $err');
    });
  }

  void joinCompetition(String competitionId) {
    socket.emit('joinCompetition', competitionId);
  }

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

  void onLeaderboardUpdate(Function(dynamic) callback) {
    socket.on('leaderboardUpdate', callback);
  }

  void onPlayerJoined(Function(dynamic) callback) {
    socket.on('playerJoined', callback);
  }

  void disconnect() {
    socket.disconnect();
  }

  void onCompetitionData(Function(dynamic) callback) {
    print('Registering competitionData listener');
    socket.off('competitionData'); // Remove previous listeners
    socket.on('competitionData', callback);
  }

  void getCompetitionData(String competitionId) {
    if (socket.connected) {
      print('Emitting getCompetitionData for $competitionId');
      socket.emit('getCompetitionData', competitionId);
    } else {
      print('Socket not connected, cannot emit getCompetitionData');
    }
  }
}
