
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.jamendo.com/v3.0';

  static String get clientId => dotenv.env['CLIENT_ID'] ?? '';
}