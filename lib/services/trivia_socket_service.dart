import 'package:socket_io_client/socket_io_client.dart' as IO;

class TriviaSocketService {
  static final TriviaSocketService _instance = TriviaSocketService._internal();
  factory TriviaSocketService() => _instance;

  late IO.Socket socket;

  TriviaSocketService._internal();

  void connect(String url) {
    socket = IO.io(
      url,
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build(),
    );
    socket.connect();
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
}