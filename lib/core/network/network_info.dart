import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstraction for checking network connectivity
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementation using connectivity_plus package
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  const NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }
}
