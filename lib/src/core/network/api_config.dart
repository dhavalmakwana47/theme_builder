import 'package:flutter/foundation.dart';

class ApiConfig {
  // Configured server host IP
  static const String serverIp = '10.151.118.115';

  // Primary base URL for Laravel API
  // On Flutter Web, use relative or localhost/IP depending on setup
  static String get baseUrl {
    return 'https://tournax.in/api/v1';
  }

  // API Key Authentication Header requirement
  static const String apiKeyHeaderName = 'X-API-KEY';
  static const String apiKey = 'YOUR_SECRET_API_KEY';

  static Map<String, String> get defaultHeaders => {
        apiKeyHeaderName: apiKey,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
}
