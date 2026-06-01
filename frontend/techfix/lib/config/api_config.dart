/// Reads the backend API base URL from the `.env` file.
/// Defaults to `http://localhost:3000` if not set.
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
}
