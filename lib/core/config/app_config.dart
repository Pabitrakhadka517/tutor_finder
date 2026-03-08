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
  /// Use your PC's local IP so physical Android devices can connect
  static const AppConfig development = AppConfig(
    baseUrl: 'http://192.168.1.67:4000/api',
    wsUrl: 'ws://192.168.1.67:4000',
  );

  /// Production config — override in main.dart
  static const AppConfig production = AppConfig(
    baseUrl: 'https://api.learnmentor.app/api',
    wsUrl: 'wss://api.learnmentor.app',
  );
}
