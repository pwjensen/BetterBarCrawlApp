import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get openRouteServiceApiKey => dotenv.env['ORS_API_KEY'] ?? '';
  static String get serverHost => dotenv.env['SERVER_HOST'] ?? 'NOT GOOD';
  static String get serverPort => dotenv.env['SERVER_PORT'] ?? 'BAD PORT';
  static String get apiBaseUrl =>
      '${dotenv.env['SERVER_HOST']}:${dotenv.env['SERVER_PORT']}';
}
