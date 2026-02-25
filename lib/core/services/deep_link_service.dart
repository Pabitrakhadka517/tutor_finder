import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service that listens for incoming deep links / app links and
/// navigates accordingly.
///
/// Supported links:
/// - `learnmentor://reset-password?token=<token>`
/// - `http(s)://*/reset-password?token=<token>`
///
/// The service is initialised once (in [AuthWrapper] or [MyApp]) and
/// keeps listening until the widget is disposed.
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  /// The navigator key used by [MaterialApp] – needed to push routes
  /// from outside a widget tree.
  final GlobalKey<NavigatorState> navigatorKey;

  DeepLinkService({required this.navigatorKey});

  /// Start listening. Should be called once during app init.
  Future<void> init() async {
    // Handle link that launched the app (cold start)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (_) {
      // No initial link — app opened normally
    }

    // Handle links received while app is running (warm start)
    _subscription = _appLinks.uriLinkStream.listen(_handleUri, onError: (_) {});
  }

  void _handleUri(Uri uri) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    // Match: */reset-password?token=...
    if (uri.path.contains('reset-password') || uri.host == 'reset-password') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        navigator.pushNamed('/reset-password', arguments: {'token': token});
      }
    }
  }

  /// Clean up when the app is done.
  void dispose() {
    _subscription?.cancel();
  }
}

/// Global navigator key shared by [MaterialApp] and [DeepLinkService].
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (_) => GlobalKey<NavigatorState>(),
);

/// Deep link service provider.
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  final key = ref.read(navigatorKeyProvider);
  return DeepLinkService(navigatorKey: key);
});
