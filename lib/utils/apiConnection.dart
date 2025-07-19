import 'package:flutter_dotenv/flutter_dotenv.dart';

final String apiUrl = dotenv.env['API_URL'] ?? 'http://16.16.149.154:3001';
final String socketUrl = dotenv.env['SOCKET_URL'] ?? 'http://16.16.149.154:3001';
