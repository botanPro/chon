import 'package:flutter_dotenv/flutter_dotenv.dart';

final String apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3001';
final String socketUrl = dotenv.env['SOCKET_URL'] ?? 'ws://localhost:3001';
