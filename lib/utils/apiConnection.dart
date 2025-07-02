import 'package:flutter_dotenv/flutter_dotenv.dart';

final String apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
final String socketUrl = dotenv.env['SOCKET_URL'] ?? 'http://localhost:3000';
