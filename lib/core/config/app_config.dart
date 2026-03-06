/// Application configuration - base URLs, timeouts, etc.
class AppConfig {
  final String baseUrl;
  final String wsUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  const AppConfig({
    required this.baseUrl,
    this.wsUrl = '',
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
  });

  /// Default development config
  static const AppConfig development = AppConfig(
    baseUrl: 'http://localhost:4000/api',
    wsUrl: 'ws://localhost:4000',
  );

  /// Production config — override in main.dart
  static const AppConfig production = AppConfig(
    baseUrl: 'https://api.learnmentor.app/api',
    wsUrl: 'wss://api.learnmentor.app',
  );
}
